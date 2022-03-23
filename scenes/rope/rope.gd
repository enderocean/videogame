extends Spatial

const SECTION = preload("res://scenes/rope/section.tscn")
const LINK = preload("res://scenes/rope/joint.tscn")

export var loops: int = 1

var offset: Vector3 = Vector3(0, 0, -0.434)
var vehicle

func _ready() -> void:
	var parent = get_parent().find_node("BlueRov", true, false)
	for i in range(loops):
		var child = addSection(parent, i)
		addLink(parent, child, i)
		parent = child


func addSection(_parent: Spatial, i: int) -> Spatial:
	var section = SECTION.instance()
	section.transform.origin = -offset + Vector3(0, 0, -0.145) * i
	
	for child in section.get_children():
		child.transform.origin = Vector3.ZERO
	
	add_child(section)
	return section


func addLink(parent: Spatial, child: Spatial, i) -> void:
	var pin = LINK.instance()
	pin.global_transform = Transform(
		Basis(
			Vector3(1, 0, 0),
			Vector3(0, 1, 0),
			Vector3(0, 0, 1)
			),
			-Vector3(0, 0, 0.145 / 2)
		)
	pin.set_node_a(parent.get_path())
	pin.set_node_b(child.get_path())
	parent.add_child(pin)
	pin.set_solver_priority(i)

