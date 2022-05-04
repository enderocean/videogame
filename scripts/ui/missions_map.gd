extends Control

var current_mission: LevelData

export var mission_panel_path: NodePath
onready var mission_panel: MissionPanel = get_node(mission_panel_path)

export var world_map_path: NodePath
onready var world_map: WorldMap = get_node(world_map_path)


func _ready() -> void:
	var next_point: MissionPoint
	for i in range(world_map.mission_points.size()):
		# Set the mission point completed if the level is present in the save data
		world_map.mission_points[i].completed = SaveManager.data.levels.has(
			world_map.mission_points[i].mission_id
		)
		world_map.mission_points[i].update_color()

		if not world_map.mission_points[i].completed:
			# Set the next point
			next_point = world_map.mission_points[i]
			world_map.current_point_index = i
			break

	# No next_point means that all the missions are completed
	if not next_point:
		# Get the last one
		next_point = world_map.mission_points[world_map.mission_points.size() - 1]
		world_map.current_point_index = world_map.mission_points.size() - 1

	world_map.goto(next_point)
	world_map.update_line()

	_on_mission_pressed(next_point)


func _on_mission_pressed(mission_point: MissionPoint) -> void:
	if not Globals.levels.has(mission_point.mission_id):
		printerr("LevelData not found for ", mission_point.mission_id)
		return

	var mission: LevelData = Globals.levels[mission_point.mission_id]
	if not mission:
		printerr("LevelData not loaded: ", mission_point.mission_id)
		return

	current_mission = mission
	world_map.goto(mission_point)
	mission_panel.show_mission(current_mission)


func _on_StartMission_pressed() -> void:
	if not current_mission:
		printerr("No mission currently selected, aborting start...")
		return

	SceneLoader.load_scene("res://scenes/ui/hud.tscn")
	SceneLoader.load_scene(current_mission.scene, true)


func _on_Back_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/menu.tscn")
