extends Control

onready var mission_ended_popup: Popup = get_node("MissionEndedPopup")
onready var mission_timer: MissionTimer = get_node("MissionTimer")

export var camera_follow_path: NodePath
onready var camera_follow: FollowCamera = get_node(camera_follow_path)
export var camera_lookat_path: NodePath
onready var camera_lookat: LookAtCamera = get_node(camera_lookat_path)

var active_level: Level


func _ready():
	SceneLoader.connect("scene_loaded", self, "_on_scene_loaded")


func _on_scene_loaded(scene: Node) -> void:
	if not scene is Level:
		return
	
	active_level = scene
	active_level.connect("finished", self, "_on_level_finished")
	
	if active_level.vehicle:
		camera_follow.target_node = active_level.vehicle.camera_target
		camera_lookat.target = active_level.vehicle.camera_target
	
	mission_timer.start_timer()

func _on_level_finished() -> void:
	mission_timer.paused = true
	show_popup()


func _on_MissionTimer_timeout() -> void:
	show_popup()


func show_popup() -> void:
	mission_ended_popup.update_objectives(active_level.objectives)
	mission_ended_popup.update_time(mission_timer.time_left)
	mission_ended_popup.show()
