extends Path
class_name Rope

export var enabled: bool = true
export var section: PackedScene
export var joint: PackedScene

export var from: NodePath
export var to: NodePath
export(int, 1, 1000) var length: int = 1

var offset: Vector3 = Vector3(0, 0, -0.434)
var sections: Array

var from_body: PhysicsBody
var to_body: PhysicsBody

func _ready() -> void:
	if not enabled:
		return

	var from_node = get_node_or_null(from)
	if not from_node:
		printerr('Path "from" of "', name, '" is not set')
		return

	var to_node = get_node_or_null(to)
	if not to_node:
		printerr('Path "to" of "', name, '" is not set')
		return

	from_body = get_body_from(from_node)
	if not from_body:
		printerr('Path "from" of "', name, '" is not a PhysicsBody, Vehicle or DeliveryTool')
		return

	to_body = get_body_from(to_node)
	if not to_body:
		printerr('Path "to" of "', name, '" is not a PhysicsBody, Vehicle or DeliveryTool')
		return
	
	var from_origin: Vector3 = from_body.global_transform.origin
	var to_origin: Vector3 = to_body.global_transform.origin
	
	# Add points to "connect" the bodies to the rope 
	curve.add_point(from_body.global_transform.origin, Vector3.ZERO, Vector3.ZERO, 0)
	curve.add_point(to_body.global_transform.origin)
	
	var points: PoolVector3Array = curve.get_baked_points()
	# Get the rope length from the path
	length = 0
	for i in range(points.size() - 1):
		var distance: float = points[i].distance_to(points[i + 1])
		var section_count: int = floor(distance / RopeSection.LENGTH)
		length += section_count
	
	print(name, " created ", length, " sections.")

	# Create the rope
	# Set the first body to be the "From"
	var parent: RigidBody = add_section(0)
	joint(from_body, parent)
	
	# Link each section of the rope
	for i in range(length):
		var child: RigidBody = add_section(i)
		add_link(parent, child, i)
		parent = child
		sections.append(child)
	
	joint(parent, to_body)

	# Make the rope follow the path
	for i in range(points.size() - 1):
		var direction: Vector3 = points[i].direction_to(points[i + 1])
		var distance: float = points[i].distance_to(points[i + 1])
		var section_count: int = ceil(distance / RopeSection.LENGTH)
		
		for j in range(section_count - 1):
			sections[i + j].global_transform.origin = points[i] -offset + (direction * -RopeSection.LENGTH) * j
	
	from_body.global_transform.origin = from_origin

func add_section(i: int) -> RigidBody:
	var part: RigidBody = section.instance()
	part.name = "Section %s" % i
	add_child(part)

	for child in part.get_children():
		child.transform.origin = Vector3.ZERO

	part.transform.origin = -offset + Vector3(0, 0, -RopeSection.LENGTH) * i
	return part


func add_link(parent: RigidBody, current: RigidBody, i: int) -> Joint:
	var pin: Generic6DOFJoint = joint.instance()
	pin.transform.origin = -Vector3(0, 0, RopeSection.LENGTH / 2)

	# Setting joint parameters
	pin.set_node_a(parent.get_path())
	pin.set_node_b(current.get_path())

	parent.add_child(pin)

	# Setting priority with rope section index
	pin.set_solver_priority(i)
	return pin


func joint(a: PhysicsBody, b: PhysicsBody):
	# Joining the last section with the to_body
	var pin: Generic6DOFJoint = joint.instance()
	b.add_child(pin)
	
	# Moves the body and the last section at the same position
	pin.global_transform.origin = b.global_transform.origin -Vector3(0, 0, RopeSection.LENGTH / 2)
	a.global_transform.origin = b.global_transform.origin
	
	# Setting joint parameters
	pin.set_node_a(a.get_path())
	pin.set_node_b(b.get_path())

# Used to get the starting position of the rope
func get_starting_point(node) -> Vector3:
	if node is Vehicle:
		return node.theter_anchor.global_transform.origin

	return node.global_transform.origin


# Used to get the correct target depending on the type of object given
func get_body_from(node) -> PhysicsBody:
	if node is Vehicle:
		return node.theter_anchor.body
	if node is DeliveryTool:
		return node.theter_anchor.body
	elif node is PhysicsBody:
		return node

	return null
