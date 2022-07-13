extends "res://scripts/delivery/delivery_area.gd"
class_name VisionArea


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body: Node) -> void:
	if not body is DeliveryObject:
		return
	
	if body.objective_type != objective_type:
		return
	
	# Make sure the object is not already in the area
	var id: int = body.get_instance_id()
	if objects.has(id):
		return
	
	objects.append(body)
	emit_signal("objects_changed", self, objects)


func _on_body_exited(body: Node) -> void:
	if not body is DeliveryObject:
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
