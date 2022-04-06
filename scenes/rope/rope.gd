extends Spatial

const SECTION: PackedScene = preload("res://scenes/rope/section.tscn")
# PinJoint behaviour but in a Generic6DOFJoint
const LINK: PackedScene = preload("res://scenes/rope/joint.tscn")

export var start: NodePath

export var loops: int = 1

var offset: Vector3 = Vector3(0, 0, -0.434)

func _ready() -> void:
	var link_start: PhysicsBody = get_node(start)
	var parent = link_start
	if not parent:
		printerr("No starting body for the rope")
		return
	
	for i in range(loops):
		var child: RigidBody = add_section(parent, i)
		add_link(parent, child, i)
		parent = child


func add_section(parent: Spatial, i: int) -> RigidBody:
	var section: RigidBody = SECTION.instance()
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
