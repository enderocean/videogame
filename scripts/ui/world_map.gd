extends Node2D
class_name WorldMap

export var camera_path: NodePath = "MapCamera"
onready var camera: MapCamera = get_node(camera_path)

export var line_path: NodePath = "Line2D"
onready var line: Line2D = get_node(line_path)

export var missions_path: NodePath = "Missions"
onready var missions: Node2D = get_node(missions_path)

var mission_points: Array
var current_point: MissionPoint

signal mission_pressed

func _ready() -> void:
	for i in range(missions.get_child_count()):
		var mission_point: MissionPoint = missions.get_child(i)
		mission_points.append(mission_point)


func update_line() -> void:
	line.clear_points()
	for point in mission_points:
		line.add_point(point.position)

func goto_current() -> void:
	current_point.active = true
	camera.goto(current_point)


func goto(id: String) -> void:
	var mission_point: MissionPoint
	for point in mission_points:
		if point.mission_id != id:
			continue
		
		mission_point = point
		break
	
	if not mission_point:
		return
	
	if current_point:
		current_point.active = false
	
	current_point = mission_point
	current_point.active = true
	
	camera.goto(mission_point)


func _on_mission_pressed(mission_point: MissionPoint) -> void:
	if current_point:
		current_point.active = false
	
	current_point = mission_point
	
	emit_signal("mission_pressed")
