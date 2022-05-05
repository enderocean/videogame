extends Control

onready var mission_ended_popup: Popup = get_node("MissionEndedPopup")
onready var mission_timer: MissionTimer = get_node("MissionTimer")

export var instructions_popup_path: NodePath
onready var instructions_popup: InstructionsPopup = get_node(instructions_popup_path)

export var objectives_text_path: NodePath
onready var objectives_text: RichTextLabel = get_node(objectives_text_path)

export var pause_menu_path: NodePath
onready var pause_menu: PauseMenu = get_node(pause_menu_path)

export var camera_follow_path: NodePath
onready var camera_follow: FollowCamera = get_node(camera_follow_path)
export var camera_lookat_path: NodePath
onready var camera_lookat: LookAtCamera = get_node(camera_lookat_path)

var active_level: Level
var active_level_data: LevelData


func _ready():
	SceneLoader.connect("scene_loaded", self, "_on_scene_loaded")


func _on_scene_loaded(scene_data: Dictionary) -> void:
	if not scene_data.scene is Level:
		return

	active_level = scene_data.scene

	# Get the LevelData of the current scene/level
	for level_data in Globals.levels.values():
		if level_data.scene != scene_data.path:
			continue

		active_level_data = level_data
		break

	if not active_level_data:
		printerr("LevelData not found for ", scene_data.path)

	active_level.connect("finished", self, "_on_level_finished")
	active_level.connect("objectives_changed", self, "_on_level_objectives_changed")

	if active_level.vehicle:
		camera_follow.target = active_level.vehicle.camera_target
		camera_lookat.target = active_level.vehicle.camera_target

	match active_level_data.id:
		# Show the instruction popup only on the practice level
		"practice":
			instructions_popup.title.text = active_level_data.title
			instructions_popup.description.text = active_level_data.description
			instructions_popup.show()
	
	# Initialize objectives text
	_on_level_objectives_changed()
	
	# Start the time with the given LevelData time
	mission_timer.start(active_level_data.time * 60)


func _on_level_objectives_changed() -> void:
	# Write the text for all objectives in the level
	var text: String = "[b]Objectives[/b]:\n"
	for i in range(active_level.objectives.keys().size()):
		var objective_key = active_level.objectives.keys()[i]
		var objective_value = active_level.objectives.values()[i]
		var progress_value
		
		if not active_level.objectives.has(objective_key):
			continue
		
		if active_level.objectives_progress.has(objective_key):
			progress_value = active_level.objectives_progress.get(objective_key)
		else:
			progress_value = 0
		
		var line: String = "{0}: {1} / {2}".format([
			Localization.get_objective_text(objective_key),
			progress_value,
			objective_value
		])
		
		# Strikethrough for finished objectives
		if progress_value >= objective_value:
			line = "[s]" + line + "[/s]"
		
		text += line + "\n"

	objectives_text.bbcode_text = text

func _on_MissionTimer_timeout() -> void:
	_on_level_finished(active_level.score)


func _on_level_finished(score: int) -> void:
	mission_timer.paused = true

	# Save the level score
	SaveManager.data.levels[active_level_data.id] = {
		"score": score,
		# Save the time it took to finish the mission
		"time": (mission_timer.minutes * 60) - mission_timer.time_left
	}
	SaveManager.save_data()

	show_popup()


func _input(event: InputEvent) -> void:
	# Pause
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide()
		else:
			pause_menu.show()


func _on_Popup_visibility_changed() -> void:
	var pause: bool = false

	if instructions_popup.visible:
		pause = true

	if mission_ended_popup.visible:
		pause = true
	if pause_menu.visible:
		pause = true

	get_tree().paused = pause


func show_popup() -> void:
	mission_ended_popup.update_objectives(active_level.objectives)
	mission_ended_popup.update_time(mission_timer.time_left)
	mission_ended_popup.show()
