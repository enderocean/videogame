extends Spatial
class_name Rope

const SECTION: PackedScene = preload("res://scenes/rope/section.tscn")
const SECTION_LENGTH: float = 0.145

# PinJoint behaviour but in a Generic6DOFJoint
const LINK: PackedScene = preload("res://scenes/rope/joint.tscn")

export var from: NodePath
export var to: NodePath
export(int, 1, 1000) var length: int = 1

var offset: Vector3 = Vector3(0, 0, -0.434)


func _ready() -> void:
	var from_node = get_node_or_null(from)
	if not from_node:
		printerr('Path "from" of "', name, '" is not set')
		return

	var to_node = get_node_or_null(to)
	if not to_node:
		printerr('Path "to" of "', name, '" is not set')
		return

	var from_body: PhysicsBody = get_body_from(from_node)
	if not from_body:
		printerr('Path "from" of "', name, '" is not a PhysicsBody or Vehicle')
		return

	var to_body: PhysicsBody = get_body_from(to_node)
	if not from_body:
		printerr('Path "to" of "', name, '" is not a PhysicsBody or Vehicle')
		return

	# length = from_body.global_transform.origin.distance_to(to_body.global_transform.origin) / SECTION_LENGTH

	# Moves the tether node to the starting position
	# global_transform.origin = get_starting_point(from_node)
	global_transform.origin = from_body.global_transform.origin

	# Face the "To" body to make easier to create the rope
	look_at(to_body.global_transform.origin, Vector3.UP)

	# Set the first body to be the "From"
	var parent: PhysicsBody = from_body
	# Link each section of the rope
	for i in range(length):
		var child: RigidBody = add_section(parent, i)
		add_link(parent, child, i)
		parent = child

	# Moves to "To" body to the position of the last rope section
	var original_position: Vector3 = to_body.global_transform.origin
	to_body.global_transform.origin = parent.global_transform.origin

	# Link the last section to the "To" body
	add_link(parent, to_body, 0)
	to_body.global_transform.origin = original_position


func add_section(parent: Spatial, i: int) -> RigidBody:
	var section: RigidBody = SECTION.instance()
	section.name = "Section %s" % i
	add_child(section)

	for child in section.get_children():
		child.transform.origin = Vector3.ZERO

	section.transform.origin = -offset + Vector3(0, 0, -0.145) * i
	return section


func add_link(parent: Spatial, child: Spatial, i: int) -> void:
	var pin: Generic6DOFJoint = LINK.instance()
	pin.transform.origin = -Vector3(0, 0, 0.145 / 2)

	# Setting joint parameters
	pin.set_node_a(parent.get_path())
	pin.set_node_b(child.get_path())

	parent.add_child(pin)

	# Setting priority with rope section index
	pin.set_solver_priority(i)


# Used to get the starting position of the rope
func get_starting_point(node) -> Vector3:
	if node is Vehicle:
		return node.theter_anchor.global_transform.origin

	return node.global_transform.origin


# Used to get the correct target depending on the type of object given
func get_body_from(node) -> PhysicsBody:
	if node is Vehicle:
		return node.vehicle_body
	elif node is PhysicsBody:
		return node

	return null
