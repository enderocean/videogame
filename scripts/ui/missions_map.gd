extends Control

var current_mission: LevelData

export var mission_panel_path: NodePath
onready var mission_panel: MissionPanel = get_node(mission_panel_path)

export var world_map_path: NodePath
onready var world_map: WorldMap = get_node(world_map_path)

func _ready() -> void:
	# TODO: Change this with user data or first mission
	current_mission = Globals.levels.practice
	
	if world_map.mission_points.size() == 0:
		return
	
	
	world_map.goto(current_mission.id)
	mission_panel.show_mission(current_mission)

func _on_StartMission_pressed() -> void:
	if not current_mission:
		return
	
	print("Start mission: ", current_mission.title)
	SceneLoader.load_scene("res://scenes/hud.tscn")
	SceneLoader.load_scene(current_mission.scene, true)
