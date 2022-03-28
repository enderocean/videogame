extends Area
class_name DeliveryArea

var objects: Array

signal objects_changed

func _on_body_entered(body: Node) -> void:
	if not body is DeliveryObject:
		return
	
	var object: DeliveryObject = body
	var id: int = object.get_instance_id()
	if objects.has(id):
		return
	
	object.delivered = true
	objects.append(id)
	emit_signal("objects_changed", objects)

func _on_body_exited(body: Node) -> void:
	if not body is DeliveryObject:
		return
	
	var object: DeliveryObject = body
	var id: int = object.get_instance_id()
	var index: int = objects.find(id)
	if index == -1:
		return
	
	object.delivered = false
	objects.remove(index)
	emit_signal("objects_changed", objects)
