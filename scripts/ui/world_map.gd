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
var current_point_index: int setget set_current_point

signal mission_pressed


func _ready() -> void:
	for i in range(missions.get_child_count()):
		var mission_point: MissionPoint = missions.get_child(i)
	# warning-ignore:return_value_discarded
		mission_point.connect("pressed", self, "_on_mission_pressed")
		mission_points.append(mission_point)


func update_line() -> void:
	line.clear_points()

	# Connect all the completed points and the next one
	for i in range(current_point_index + 1):
		if i >= mission_points.size():
			break
		line.add_point(mission_points[i].position)


func goto_with_id(id: String) -> void:
	# Get the mission point with it's id
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


func goto(mission_point: MissionPoint) -> void:
	if not mission_point:
		printerr("Given point not set")
		return

	if current_point:
		current_point.active = false

	current_point = mission_point
	current_point.active = true
	camera.goto(current_point)


func set_current_point(value: int) -> void:
	current_point_index = value
	current_point = mission_points[value]


func _on_mission_pressed(mission_point: MissionPoint) -> void:
	if current_point:
		current_point.active = false

	emit_signal("mission_pressed", mission_point)
