extends Node
class_name SpeedsObjective

export var vehicle_path: NodePath
var vehicle: Vehicle

signal completed(speeds_done)

var speeds_switched: Array
var speeds_count: int

func _ready() -> void:
	add_to_group("objectives_nodes")
	vehicle = get_node(vehicle_path)
	vehicle.vehicle_body.connect("speed_changed", self, "_on_speed_changed")
	speeds_count = vehicle.vehicle_body.speeds.size()


func _on_speed_changed(index: int) -> void:
	if speeds_switched.has(index):
		return
	
	speeds_switched.append(index)
	emit_signal("completed", speeds_switched.size())
