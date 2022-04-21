extends Spatial

export var attach1: NodePath
export var attach2: NodePath
export var attach3: NodePath
export var attach4: NodePath

export var pins = [0, 20, 10, 40]

export var real_pins = [0, 20, 10, 40]

onready var fish_net = get_node("fishing_net")

var mdt = MeshDataTool.new()

var rope_thickness = 0.02
var rope_radial_segments = 16
var rope_rings = 4


func create_attach(nb_pin, attach):
	fish_net.set_point_pinned(pins[nb_pin], true)

	var soft_rope_1 = SoftRope.new()
	soft_rope_1.create_rope(0.01)
	var soft_rope_2 = SoftRope.new()
	soft_rope_2.create_rope(0.01)
	soft_rope_2.second_rope = soft_rope_1
	soft_rope_2.fishing_net = fish_net
	soft_rope_2.attach_np = attach
	soft_rope_2.pin = pins[nb_pin]

	add_child(soft_rope_1)
	add_child(soft_rope_2)
	
	var initial_pos = get_node(attach).global_transform.origin

	soft_rope_1.global_transform.origin = fish_net.global_transform.xform(mdt.get_vertex(real_pins[nb_pin]))
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
	
	var mdt2 = MeshDataTool.new()
	mdt2.create_from_surface(soft_rope_2.mesh, 0)

	var diff = soft_rope_2.global_transform.xform(mdt2.get_vertex(soft_rope_2.pins_beg[0])).distance_squared_to(
		soft_rope_1.global_transform.origin
	)
	var length = (
		soft_rope_2.global_transform.xform(mdt2.get_vertex(soft_rope_2.pins_end[0])).distance_squared_to(
			soft_rope_1.global_transform.origin
		)
		- diff
	)
	var distance = (diff * 2) + length
	var scale_factor = distance / length

	soft_rope_2.scale.y = soft_rope_2.scale.y * (scale_factor * 2)
	
	var area = Area.new()
	var collision_shape = CollisionShape.new()
	collision_shape.shape = soft_rope_2.mesh.create_convex_shape()
	area.add_child(collision_shape)
	add_child(area)
	area.global_transform = soft_rope_2.global_transform
	area.connect("area_shape_entered", soft_rope_2, "_on_Area_area_shape_entered")

func _ready():
	var mesh = fish_net.get_mesh()
	mdt.create_from_surface(mesh, 0)

	if !attach1.is_empty():
		create_attach(0, attach1)
	if !attach2.is_empty():
		create_attach(1, attach2)
	if !attach3.is_empty():
		create_attach(2, attach3)
	if !attach4.is_empty():
		create_attach(3, attach4)
