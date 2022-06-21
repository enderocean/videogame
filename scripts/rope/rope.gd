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
	
	# Create the rope along the path
	for i in range(points.size() - 1):
		var direction: Vector3 = points[i].direction_to(points[i + 1])
		var distance: float = points[i].distance_to(points[i + 1])
		var section_count: int = distance / RopeSection.LENGTH
		
		# Create sections between the current and next point in the path 
		for j in range(section_count):
			var section_index: int = i + j
			# Get the correct position in the path
			var position: Vector3 = points[i] + (direction * -distance) * j
			var next_position: Vector3 = points[i + 1] + (direction * -distance) * j
			var joint_position: Vector3 = position - direction * (distance / 2)
			var next_joint_position: Vector3 = next_position - direction * (distance / 2)
			var joints_direction: Vector3 = joint_position.direction_to(next_joint_position)
			
			if section_index == 0:
				position = from_body.global_transform.origin
				joint_position = position - (joints_direction * -distance)
			# If last section, set the next position to the connected body's position
			elif section_index == points.size() - 1:
				next_position = to_body.global_transform.origin
			
			var distance_joints: float = joint_position.distance_to(next_joint_position)
			if section_index == 0:
				position = position - (joints_direction * -distance_joints / 2)

			var distance_positions: float = position.distance_to(next_position)
			
			# Section
			var section: RigidBody = create_section(joint_position, distance_joints)
			
			# Make the section look at the next position
			section.look_at_from_position(position, next_position, Vector3.UP)
			
			# Joint
			var previous: PhysicsBody = null
#			var joint_position: Vector3 = section.global_transform.origin - direction * (distance / 2)
			if section_index == 0:
				previous = from_body
				joint_position = from_body.global_transform.origin
			else:
				previous = sections[section_index - 1]
			
			var joint: Joint = joint(joint_position, previous, section)
			sections.append(section)
			joints.append(joint)

		
		# Wait a little bit, this is necessary because we are modifying collision shapes
		# Not waiting here will increase the load time of the scene
		yield(get_tree().create_timer(0.001), "timeout")
	
	# Joint to connect the last section to the connected body
	joint(to_body.global_transform.origin, sections[sections.size() - 1], to_body)
	
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
	
#	get_tree().paused = true
	emit_signal("created")
	created = true


#func _physics_process(delta: float) -> void:
#	if created:
#		for i in sections.size():
#			line_renderer.points[i] = sections[i].global_transform.origin


func create_section(pos: Vector3, section_len: float) -> RigidBody:
	var section: RigidBody = self.section.instance()
	add_child(section)
	
	section.length = section_len
	section.global_transform.origin = pos
	
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
