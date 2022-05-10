extends SoftBody

class_name SoftRope

var initial_length = 0.01
var rope_thickness = 0.02
var rope_radial_segments = 16
var rope_rings = 4

var mdt = MeshDataTool.new()
var attach_np
var fishing_net
var rope_mesh
var second_rope
var pin
var pins_beg = []
var pins_end = []


func set_rope_pins():
	mdt.create_from_surface(mesh, 0)

	for id in mdt.get_vertex_count():
		if mdt.get_vertex(id).z == 0:
			if mdt.get_vertex(id).y < 0:
				pins_beg.append(id)
				self.set_point_pinned(id, true)
				if (second_rope):
					second_rope.set_point_pinned(id, true)
			else:
				pins_end.append(id)
				set_point_pinned(id, true)
				if (second_rope):
					second_rope.set_point_pinned(id, true)
				var edges = mdt.get_vertex_edges(id)
				for i in edges.size():
					pins_end.append(mdt.get_edge_vertex(edges[i], 1))
					set_point_pinned(mdt.get_edge_vertex(edges[i], 1), true)
					if (second_rope):
						second_rope.set_point_pinned(mdt.get_edge_vertex(edges[i], 1), true)


func create_rope(rope_length: float):
	rope_mesh = CylinderMesh.new()

	rope_mesh.radial_segments = rope_radial_segments
	rope_mesh.rings = rope_rings
	rope_mesh.height = rope_length
	rope_mesh.top_radius = rope_thickness
	rope_mesh.bottom_radius = rope_thickness

	self.mesh = rope_mesh

func unpin():
	for id in range(1, pins_end.size()):
		self.set_point_pinned(pins_end[id], false)
		if (second_rope):
			second_rope.set_point_pinned(pins_end[id], false)


func _ready():
	self.linear_stiffness = 0.5
