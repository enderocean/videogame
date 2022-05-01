extends Spatial

export var pospin1: NodePath
export var pospin2: NodePath
export var pospin3: NodePath
export var pospin4: NodePath

export var attach1: NodePath
export var attach2: NodePath
export var attach3: NodePath
export var attach4: NodePath

export var overrite_pins = [-1,-1,-1,-1]

onready var attachs = [attach1, attach2, attach3, attach4]
onready var pospins = [pospin1, pospin2, pospin3, pospin4]
var soft_ropes = []
onready var fish_net = get_node("fishing_net")

var mdt = MeshDataTool.new()


var rope_thickness = 0.02
var rope_radial_segments = 16
var rope_rings = 4

func get_closest_pins(rope_nb):
	var real_pin = 0
	var img_pin = 0
	var distance = 10000

	for id in mdt.get_vertex_count():
		var tmp = global_transform.xform(mdt.get_vertex(id)).distance_squared_to(pospins[rope_nb].global_transform.origin)
		if tmp < distance:
			distance = tmp
			real_pin = id

	var pos_pin = global_transform.xform(mdt.get_vertex(real_pin))

	for id in mdt.get_vertex_count():
		var tmp = global_transform.xform(fish_net.get_point_transform(id))
		if (tmp == pos_pin):
			return ([real_pin, id])

	return ([real_pin, img_pin])

func cut_rope(area, rope_id, cut_pos):
	if cut_pos < 0 or cut_pos > 1:
		return
	area.queue_free()
	soft_ropes[rope_id][1].queue_free()
	soft_ropes[rope_id][0].queue_free()
	replace_attach(rope_id, cut_pos)

func replace_attach(rope_nb, cut_pos):
	var soft_rope_1 = SoftRope.new()
	soft_rope_1.create_rope(0.01)
	var soft_rope_2 = SoftRope.new()
	soft_rope_2.create_rope(0.01)
	soft_rope_2.second_rope = soft_rope_1

	add_child(soft_rope_1)
	add_child(soft_rope_2)

	soft_rope_1.global_transform.origin = pospins[rope_nb].global_transform.origin
	soft_rope_2.global_transform.origin = attachs[rope_nb].global_transform.origin


	var new_pos = soft_rope_2.global_transform.origin.linear_interpolate(
		soft_rope_1.global_transform.origin, 0.5)
	soft_rope_2.global_transform.origin = new_pos
	
	soft_rope_2.look_at(soft_rope_1.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_2.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))

	soft_rope_1.look_at(soft_rope_2.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_1.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))
	
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
	
	#debut du bordel
	soft_rope_1.scale.y = soft_rope_2.scale.y * (1 - cut_pos)
	soft_rope_2.scale.y = soft_rope_2.scale.y * cut_pos
	soft_rope_1.global_transform.origin = pospins[rope_nb].global_transform.origin
	soft_rope_2.global_transform.origin = attachs[rope_nb].global_transform.origin
	
	new_pos = soft_rope_2.global_transform.origin.linear_interpolate(
		soft_rope_1.global_transform.origin, cut_pos/2)
	
	var new_pos2 = soft_rope_1.global_transform.origin.linear_interpolate(
		soft_rope_2.global_transform.origin, (1 - cut_pos)/2)
	soft_rope_2.global_transform.origin = new_pos
	soft_rope_1.global_transform.origin = new_pos2
	soft_rope_2.unpin()
	fish_net.set_point_pinned(overrite_pins[rope_nb], false)

	
func create_attach(rope_nb):
	var closest_pins = get_closest_pins(rope_nb)
	if (overrite_pins[rope_nb] != -1):
		closest_pins[1] = overrite_pins[rope_nb]
	overrite_pins[rope_nb] = closest_pins[1]
	fish_net.set_point_pinned(closest_pins[1], true)

	var soft_rope_1 = SoftRope.new()
	soft_rope_1.create_rope(0.01)
	var soft_rope_2 = SoftRope.new()
	soft_rope_2.create_rope(0.01)
	soft_rope_2.second_rope = soft_rope_1

	add_child(soft_rope_1)
	add_child(soft_rope_2)

	soft_rope_1.global_transform.origin = pospins[rope_nb].global_transform.origin
	soft_rope_2.global_transform.origin = attachs[rope_nb].global_transform.origin


	var new_pos = soft_rope_2.global_transform.origin.linear_interpolate(
		soft_rope_1.global_transform.origin, 0.5)
	soft_rope_2.global_transform.origin = new_pos
	
	soft_rope_2.look_at(soft_rope_1.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_2.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))

	soft_rope_1.look_at(soft_rope_2.global_transform.origin, Vector3(1, 0, 0))
	soft_rope_1.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))
	
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


	var area = AreaRope.new()
	area.set_rope(soft_rope_2, rope_nb + 1)
	add_child(area)
	area.global_transform = soft_rope_2.global_transform
	soft_ropes.append([soft_rope_1, soft_rope_2, soft_rope_2.scale.y])

func _ready():
	var mesh = fish_net.get_mesh()
	mdt.create_from_surface(mesh, 0)
	for i in attachs.size():
		if (!attachs[i].is_empty() and !pospins[i].is_empty()):
			attachs[i] = get_node(attachs[i])
			pospins[i] = get_node(pospins[i])
			create_attach(i)
