extends Spatial
class_name Rope

const SECTION_LENGTH: float = 0.145

export var section: PackedScene
export var joint: PackedScene

export var from: NodePath
export var to: NodePath
export(int, 1, 1000) var length: int = 1
export(float, 0.1, 100) var pulling_speed: float = 1.0

var offset: Vector3 = Vector3(0, 0, -0.434)
var sections: Array

var pulling: bool = false
var pulling_section
var pulling_direction: Vector3
var pulling_distance: float
var pulling_destination: Vector3

var timer: Timer
var tween: Tween
var line_renderer: LineRenderer

var from_body: PhysicsBody
var to_body: PhysicsBody
var to_body_origin: Vector3

signal pulled

func _ready() -> void:
	if not timer:
		timer = Timer.new()
		timer.wait_time = 1.0
		add_child(timer)
	
	if not tween:
		tween = Tween.new()
		add_child(tween)
	
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
	
	# Connect to the catched event of the delivery tool to make the rope pull
	if from_node is DeliveryTool:
		from_node.connect("catched", self, "_on_delivery_tool_catched")
	
	to_body_origin = to_body.global_transform.origin

	# Moves the tether node to the starting position
	global_transform.origin = from_body.global_transform.origin

	# Face the "To" body to make easier to create the rope
	look_at(to_body.global_transform.origin, Vector3.UP)

	# Set the first body to be the "From"
	var parent: PhysicsBody = from_body
	# Link each section of the rope
	for i in range(length):
		var child: RigidBody = add_section(parent, i)
		
		if i > 0:
			child.previous_joint = parent.joint
		
		child.joint = add_link(parent, child, i)
		parent = child
		sections.append(child)
	
	# Moves to "To" body to the position of the last rope section
	var original_position: Vector3 = to_body.global_transform.origin
	to_body.global_transform.origin = parent.global_transform.origin

	# Link the last section to the "To" body
	add_link(parent, to_body, 0)
	to_body.global_transform.origin = original_position


func _physics_process(delta: float) -> void:
	if pulling:
		if to_body.global_transform.origin.distance_to(pulling_destination) < SECTION_LENGTH:
			pulling = false
			emit_signal("pulled")
		
		to_body.global_transform.origin = lerp(to_body.global_transform.origin, pulling_destination, delta * pulling_speed)


func add_section(parent: Spatial, i: int) -> RigidBody:
	var part: RigidBody = section.instance()
	part.name = "Section %s" % i
	add_child(part)

	for child in part.get_children():
		child.transform.origin = Vector3.ZERO

	part.transform.origin = -offset + Vector3(0, 0, -0.145) * i
	return part


func add_link(parent: Spatial, child: Spatial, i: int) -> Joint:
#	var pin: Generic6DOFJoint = LINK.instance()
	var pin: Generic6DOFJoint = joint.instance()
	pin.transform.origin = -Vector3(0, 0, 0.145 / 2)

	# Setting joint parameters
	pin.set_node_a(parent.get_path())
	pin.set_node_b(child.get_path())

	parent.add_child(pin)

	# Setting priority with rope section index
	pin.set_solver_priority(i)
	return pin


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


func pull() -> void:
	pulling_distance = sections.size() * SECTION_LENGTH
	pulling_direction = to_body_origin.direction_to(global_transform.origin)
	pulling_destination = to_body_origin - pulling_direction * pulling_distance
	pulling = true


func _on_delivery_tool_catched() -> void:
	pull()
