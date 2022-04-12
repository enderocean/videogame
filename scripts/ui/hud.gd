extends Control

onready var mission_ended_popup: Popup = get_node("MissionEndedPopup")
onready var mission_timer: MissionTimer = get_node("MissionTimer")

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
	
	if active_level.vehicle:
		camera_follow.target = active_level.vehicle.camera_target
		camera_lookat.target = active_level.vehicle.camera_target
	
	# Start the time with the given LevelData time
	mission_timer.start(active_level_data.time * 60)

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


func show_popup() -> void:
	mission_ended_popup.update_objectives(active_level.objectives)
	mission_ended_popup.update_time(mission_timer.time_left)
	mission_ended_popup.show()
