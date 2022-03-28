extends Area
class_name DeliveryArea

var objects: Array

signal objects_changed

func _on_body_entered(body: Node) -> void:
	var id: int = body.get_instance_id()
	if objects.has(id):
		return
	
	objects.append(id)
	emit_signal("objects_changed")

func _on_body_exited(body: Node) -> void:
	var id: int = body.get_instance_id()
	if not objects.has(id):
		return
	
	objects.remove(id)
	emit_signal("objects_changed")
