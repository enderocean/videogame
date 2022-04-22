extends Spatial
class_name DeliveryArea

# TODO: Create a nice way to select any sound with a custom inspector maybe?
const RADIO_SOUNDS: Array = [
	"nice",
	"good_job",
	"well_done"
]

export(Level.ObjectiveType) var objective_type = Level.ObjectiveType.GRIPPER

## Emit signal only when objects enter the area
export var only_enter: bool = false

onready var group: String = "objective_%s" % str(objective_type).to_lower()

var objects: Array

signal objects_changed


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

	# Play random sound from array
	RadioSounds.play(RADIO_SOUNDS[RadioSounds.rand.randi_range(0, RADIO_SOUNDS.size() - 1)])

	# Make the object delivered
	object.delivered = true
	objects.append(id)
	emit_signal("objects_changed", objects)


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
	emit_signal("objects_changed", objects)
