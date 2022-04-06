extends Spatial
class_name DeliveryArea

var objects: Array

signal objects_changed

func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return
	
	# Make sure the object is not already in the area
	var object: DeliveryObject = body
	var id: int = object.get_instance_id()
	if objects.has(id):
		return
	
	# Make the object delivered
	object.delivered = true
	objects.append(id)
	emit_signal("objects_changed", objects)

func _on_body_exited(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return
	
	# Make sure the object is in the area
	var object: DeliveryObject = body
	var id: int = object.get_instance_id()
	var index: int = objects.find(id)
	if index == -1:
		return
	
	# Make the object not delivered
	object.delivered = false
	objects.remove(index)
	emit_signal("objects_changed", objects)