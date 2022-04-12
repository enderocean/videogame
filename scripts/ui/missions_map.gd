extends Control

var current_mission: LevelData

export var mission_panel_path: NodePath
onready var mission_panel: MissionPanel = get_node(mission_panel_path)

export var world_map_path: NodePath
onready var world_map: WorldMap = get_node(world_map_path)

func _ready() -> void:
	# Set the first point as current
	world_map.current_point = world_map.mission_points[0]
	_on_mission_pressed()

func _on_mission_pressed() -> void:
	var current_point: MissionPoint = world_map.current_point
	if not Globals.levels.has(current_point.mission_id):
		printerr("Level not found with id: ", current_point.mission_id)
		return
	
	var mission: LevelData = Globals.levels[current_point.mission_id]
	if not mission:
		printerr("LevelData not loaded: ", current_point.mission_id)
		return
	
	current_mission = mission
	world_map.goto_current()
	mission_panel.show_mission(current_mission)

func _on_StartMission_pressed() -> void:
	if not current_mission:
		return
	
	print("Start mission: ", current_mission.title)
	SceneLoader.load_scene("res://scenes/hud.tscn")
	SceneLoader.load_scene(current_mission.scene, true)
