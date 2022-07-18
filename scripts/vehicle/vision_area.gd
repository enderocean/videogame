extends "res://scripts/delivery/delivery_area.gd"
class_name VisionArea

export var vehicle_path: NodePath
var vehicle: Vehicle

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	vehicle = get_node(vehicle_path)


func _on_body_entered(body: Node) -> void:
	if not body is FindableObject:
		return
	
	if body.objective_type != objective_type:
		return
	
	if body.need_lights and vehicle.vehicle_body.lights[0].light_energy == 0:
		return
	
	# Make sure the object is not already in the area
	var id: int = body.get_instance_id()
	if objects.has(id):
		return
	
	objects.append(body)
	emit_signal("objects_changed", self, objects)


func _on_body_exited(body: Node) -> void:
	if not body is FindableObject:
		return
	
	if body.objective_type != objective_type:
		return
	
	# Make sure the object is stored
	var id: int = body.get_instance_id()
	var index: int = objects.find(id)
	if index == -1:
		return
	
	objects.remove(index)
	emit_signal("objects_changed", self, objects)
