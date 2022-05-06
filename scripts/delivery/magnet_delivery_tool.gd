extends "res://scripts/delivery/delivery_tool.gd"
class_name MagnetDeliveryTool

export var area: NodePath

var detected_object: DeliveryObject

func _ready() -> void:
	.ready()
	objective_type = Globals.ObjectiveType.MAGNET
	(get_node(area) as Area).connect("area_entered", self, "_on_body_entered")


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

	# Don't play a radio sound for the vacuum
	if objective_type != Globals.ObjectiveType.VACUUM:
		# Play random sound from array
		RadioSounds.play(RADIO_SOUNDS[RadioSounds.rand.randi_range(0, RADIO_SOUNDS.size() - 1)])

	# Make the object delivered
	object.delivered = true
	objects.append(id)
	emit_signal("objects_changed", self, objects)


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
	emit_signal("objects_changed", self, objects)
