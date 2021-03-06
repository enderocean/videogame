extends Spatial
class_name DeliveryArea

# TODO: Create a nice way to select any sound with a custom inspector maybe?
const RADIO_SOUNDS: Array = [
	"nice",
	"good_job",
	"well_done"
]

export(Globals.ObjectiveType) var objective_type = Globals.ObjectiveType.GRIPPER

## Emit signal only when objects enter the area
export var only_enter: bool = false

var objects: Array

signal objects_changed(area, objects)


func _ready() -> void:
	add_to_group("objectives_nodes")


func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return

	var object: DeliveryObject = body
	if object.objective_type != objective_type:
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
	if object.objective_type != objective_type:
		return
	
	var id: int = object.get_instance_id()
	var index: int = objects.find(id)
	if index == -1:
		return

	# Make the object not delivered
	object.delivered = false
	objects.remove(index)
	emit_signal("objects_changed", self, objects)
