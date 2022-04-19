extends Spatial

export var attach1: NodePath
export var attach2: NodePath
export var attach3: NodePath
export var attach4: NodePath

export var pins = [0, 20, 10, 40]

onready var fish_net = get_node("fishing_net")

var mdt = MeshDataTool.new()

var rope_thickness = 0.02
var rope_radial_segments = 16
var rope_rings = 4


func create_attach(pin):
	fish_net.set_point_pinned(pin, true)

	var soft_rope_1 = SoftRope.new()
	soft_rope_1.create_rope(0.01)
	var soft_rope_2 = SoftRope.new()
	soft_rope_2.create_rope(0.01)
	soft_rope_2.second_rope = soft_rope_1
	soft_rope_2.fishing_net = fish_net
	soft_rope_2.attach_np = attach1
	soft_rope_2.pin = pin

	add_child(soft_rope_1)
	add_child(soft_rope_2)

	var initial_pos = get_node(attach1).global_transform.origin
	soft_rope_1.global_transform.origin = fish_net.global_transform.xform(mdt.get_vertex(pin))
	soft_rope_2.global_transform.origin = initial_pos

	soft_rope_2.look_at(soft_rope_1.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_2.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))

	soft_rope_1.look_at(soft_rope_2.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_1.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))

	var new_pos = soft_rope_2.global_transform.origin.linear_interpolate(
		soft_rope_1.global_transform.origin, 0.5
	)
	soft_rope_2.global_transform.origin = new_pos

	soft_rope_2.set_rope_pins()
	mdt.create_from_surface(soft_rope_2.mesh, 0)

	var diff = soft_rope_2.global_transform.xform(mdt.get_vertex(soft_rope_2.pins_beg[0])).distance_squared_to(
		soft_rope_1.global_transform.origin
	)
	var length = (
		soft_rope_2.global_transform.xform(mdt.get_vertex(soft_rope_2.pins_end[0])).distance_squared_to(
			soft_rope_1.global_transform.origin
		)
		- diff
	)
	var distance = (diff * 2) + length
	var scale_factor = distance / length

	soft_rope_2.scale.y = soft_rope_2.scale.y * (scale_factor * 2)
	#soft_rope_2.cut_rope(0.5)


func _ready():
	var mesh = fish_net.get_mesh()
	mdt.create_from_surface(mesh, 0)

	if !attach1.is_empty():
		create_attach(pins[0])
	if !attach2.is_empty():
		create_attach(pins[1])
	if !attach3.is_empty():
		create_attach(pins[2])
	if !attach4.is_empty():
		create_attach(pins[3])
