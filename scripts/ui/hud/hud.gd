extends Control

onready var mission_ended_popup: Popup = get_node("MissionEndedPopup")
onready var mission_timer: MissionTimer = get_node("MissionTimer")

export var instructions_popup_path: NodePath
onready var instructions_popup: InstructionsPopup = get_node(instructions_popup_path)

export var collectible_popup_path: NodePath
onready var collectible_popup: CollectiblePopup = get_node(collectible_popup_path)

export var objectives_text_path: NodePath
onready var objectives_text: RichTextLabel = get_node(objectives_text_path)

export var pause_menu_path: NodePath
onready var pause_menu: PauseMenu = get_node(pause_menu_path)

export var informations_panel_path: NodePath
onready var informations_panel: InformationsPanel = get_node(informations_panel_path)

export var camera_follow_path: NodePath
onready var camera_follow: FollowCamera = get_node(camera_follow_path)
export var camera_lookat_path: NodePath
onready var camera_lookat: LookAtCamera = get_node(camera_lookat_path)

var active_level: Level
var active_level_data: LevelData


func show_popup() -> void:
	mission_ended_popup.update_stars(active_level.score, active_level_data.stars_enabled)
	mission_ended_popup.update_objectives(active_level.objectives, active_level.objectives_progress)
	mission_ended_popup.update_time(mission_timer.time_left)
	mission_ended_popup.show()


func update_score() -> void:
	if not active_level_data.stars_enabled:
		return
	
	var elapsed_time: float = (active_level_data.time * 60) - mission_timer.time_left
	
	# Check the time
	for i in range(active_level_data.stars.size()):
		var index: int = (active_level_data.stars.size() - 1) - i 
		active_level.score = (index + 1) * 1000
		
		if elapsed_time <= active_level_data.stars[index]:
			break
		
		if index == 0:
			active_level.score = 0


	# Check the penalities
	for penalty in active_level.penalties:
		active_level.score -= penalty.points
	
	print("Score in stars: ", float(active_level.score / 1000.0))
	if active_level.score <= 0:
		_on_level_finished(false)


func _ready():
	set_physics_process(false)
# warning-ignore:return_value_discarded
	SceneLoader.connect("scene_loaded", self, "_on_scene_loaded")


func _physics_process(delta: float) -> void:
	if active_level.vehicle:
		informations_panel.depth_value.text = "%0.2fm" % active_level.get_vehicle_depth()
		informations_panel.compass_texture.rect_rotation = active_level.get_vehicle_orientation()


func _input(event: InputEvent) -> void:
	# Pause
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide()
		else:
			pause_menu.show()


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
# warning-ignore:return_value_discarded
	active_level.connect("finished", self, "_on_level_finished")
# warning-ignore:return_value_discarded
	active_level.connect("objectives_changed", self, "_on_level_objectives_changed")
# warning-ignore:return_value_discarded
	active_level.connect("collectible_obtained", self, "_on_collectible_obtained")
# warning-ignore:return_value_discarded
	active_level.connect("penality_added", self, "_on_penality_added")
	
	if active_level.vehicle:
	# warning-ignore:return_value_discarded
		active_level.vehicle.vehicle_body.connect("speed_changed", self, "_on_vehicle_speed_changed")
	# warning-ignore:return_value_discarded
		active_level.vehicle.vehicle_body.connect("tool_changed", self, "_on_vehicle_tool_changed")
		camera_follow.target = active_level.vehicle.camera_target
		camera_lookat.target = active_level.vehicle.camera_target
		
		# Create hud speeds indicators
		informations_panel.create_speed_indicators(active_level.vehicle.vehicle_body.speeds.size())
		# Show the current speed
		_on_vehicle_speed_changed(active_level.get_vehicle_speed())
		# Initialize tool text
		_on_vehicle_tool_changed(active_level.vehicle.vehicle_body.vehicle_tool_index)

	# Initialize objectives text
	_on_level_objectives_changed()
	
	set_physics_process(true)
	
	# Start the time with the given LevelData time
	if active_level_data:
		mission_timer.paused = false
		mission_timer.start(active_level_data.time * 60)
		match active_level_data.id:
			# Show the instruction popup only on the practice level
			"practice":
				instructions_popup.title.text = active_level_data.title
				instructions_popup.description.text = active_level_data.description
				instructions_popup.show()
	else:
		printerr("LevelData not found for ", scene_data.path)


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
	_on_level_finished()


func _on_level_finished(update_score: bool = true) -> void:
	mission_timer.paused = true
	
	if update_score:
		update_score()
	
	# Save the level score
	SaveManager.data.levels[active_level_data.id] = {
		"score": active_level.score,
		# Save the time it took to finish the mission
		"time": (mission_timer.minutes * 60) - mission_timer.time_left
	}
	SaveManager.save_data()

	show_popup()


func _on_penality_added() -> void:
	update_score()


func _on_collectible_obtained(id: String) -> void:
	var collectible: CollectibleData = Globals.collectibles.get(id)
	if not collectible:
		return
	
	collectible_popup.title.text = collectible.title
	collectible_popup.description.bbcode_text = collectible.description
	if collectible.image:
		collectible_popup.image.texture = load(collectible.image)
	
	collectible_popup.show()


func _on_Popup_visibility_changed() -> void:
	var pause: bool = false

	if instructions_popup.visible:
		pause = true
	if collectible_popup.visible:
		pause = true
	if mission_ended_popup.visible:
		pause = true
	if pause_menu.visible:
		pause = true

	mission_timer.paused = pause
	get_tree().paused = pause


func _on_vehicle_speed_changed(index: int) -> void:
	informations_panel.set_current_speed(index)


func _on_vehicle_tool_changed(index: int) -> void:
	var vehicle_body = active_level.vehicle.vehicle_body
	informations_panel.tool_value.text = Localization.get_vehicle_tool_text(vehicle_body.vehicle_tools[vehicle_body.vehicle_tool_index])
