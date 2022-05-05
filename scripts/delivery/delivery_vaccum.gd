extends "res://scripts/delivery/delivery_area.gd"
class_name DeliveryVaccum

var removed_bodys = []

onready var end_pipe = get_node("Position3D")

var vaccum_speed = 10

func _physics_process(delta):
	for id in objects.size():
		if (removed_bodys.find(objects[id]) == -1):
			var object = instance_from_id(objects[id])
			object.global_transform.origin = object.global_transform.origin.linear_interpolate(end_pipe.global_transform.origin, (delta * vaccum_speed))
			if (object.global_transform.origin.distance_squared_to(end_pipe.global_transform.origin) < 0.01):
				removed_bodys.append(objects[id])
				object.queue_free()
				emit_signal("objects_changed", self, objects)

func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable

	if not body is DeliveryObject:
		return

	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return

	# Make sure the object is not already in the area
	var id: int = object.get_instance_id()
	if objects.has(id):
		return
	
	# Make the object delivered
	object.delivered = true
	objects.append(id)


func _on_body_exited(body: Node) -> void:
	if only_enter:
		return
	
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
