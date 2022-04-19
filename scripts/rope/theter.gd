extends "res://scripts/rope/rope.gd"

export var vehicle_path: NodePath


func _ready() -> void:
	var vehicle: Vehicle = get_node_or_null(vehicle_path)
	if not vehicle:
		printerr("Vehicle not set on: ", name)
		return

	from = vehicle.body

	._ready()
