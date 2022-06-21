extends Path
class_name Rope

export var enabled: bool = true
export var section: PackedScene
export var joint: PackedScene

export var from: NodePath
export var to: NodePath

var offset: Vector3 = Vector3(0, 0, -0.434)
var sections: Array
var joints: Array

var from_body: PhysicsBody
var to_body: PhysicsBody

var from_origin: Vector3
var to_origin: Vector3

var line_renderer: LineRenderer
var created: bool = false

signal created


func _ready() -> void:
	if not enabled:
		return
	
	add_to_group("ropes")


func initialize():
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
	
	from_origin = from_body.global_transform.origin
	to_origin = to_body.global_transform.origin
	
	# Add points to "connect" the bodies to the rope 
	curve.add_point(from_body.global_transform.origin, Vector3.ZERO, Vector3.ZERO, 0)
	curve.add_point(to_body.global_transform.origin)
	
	var points: PoolVector3Array = curve.get_baked_points()
	var iterate_from_start: bool = points[0].distance_to(from_body.global_transform.origin) < points[0].distance_to(to_body.global_transform.origin)
	
	# Create the rope along the path
	for i in range(points.size()):
		var index: int = i if iterate_from_start else (points.size() - 1) - i
		var previous_index: int = index - 1 if iterate_from_start else index + 1
		var next_index: int = index + 1 if iterate_from_start else index - 1
		
		if iterate_from_start and next_index > points.size() - 1:
			continue
		elif not iterate_from_start and next_index > points.size() - 1:
			continue
		
		# Joint
		var previous: PhysicsBody = null
		if i == 0:
			previous = from_body if iterate_from_start else to_body
		else:
			previous = sections[i - 1]
		
		var direction: Vector3 = points[index].direction_to(points[next_index])
		var distance: float = points[index].distance_to(points[next_index])
		var section: RigidBody = create_section(distance)
		section.look_at_from_position(points[index] + (direction * (distance / 2)), points[next_index], Vector3.UP)
		
		var joint: Joint = joint(points[index], previous, section)
		sections.append(section)
	
	# Joint to connect the last section to the connected body
	if iterate_from_start:
		joint(to_body.global_transform.origin, sections[sections.size() - 1], to_body)
	else:
		joint(to_body.global_transform.origin, sections[0], to_body)
	
	# Rope visuals
#	line_renderer = LineRenderer.new()
#	line_renderer.startThickness = 0.01
#	line_renderer.endThickness = 0.01
#	line_renderer.drawCaps = true
#	line_renderer.drawCorners = false
#	line_renderer.points.clear()
#
#	for section in sections:
#		line_renderer.points.append(section.global_transform.origin)
#
#	add_child(line_renderer)
	
	emit_signal("created")
	created = true


#func _physics_process(delta: float) -> void:
#	if created:
#		for i in sections.size():
#			line_renderer.points[i] = sections[i].global_transform.origin


func create_section(section_len: float) -> RigidBody:
	var section: RigidBody = self.section.instance()
	add_child(section)
	section.length = section_len
	return section


func joint(pos: Vector3, a: PhysicsBody, b: PhysicsBody) -> Joint:
	var joint: Joint = self.joint.instance()
	a.add_child(joint)
	
	joint.global_transform.origin = pos
	# Setting joint parameters
	joint.set_node_a(a.get_path())
	joint.set_node_b(b.get_path())
	return joint
	

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
