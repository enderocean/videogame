extends "res://scripts/vehicle/vehicle_tool.gd"
class_name CutterTool

func _on_RightCutArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if (area.rope_id):
		var parent = area.get_parent()

		var node_point = get_node("CutRightRigidBody/RightCutArea")
		var p = parent.global_transform.xform(node_point.global_transform.origin)
		var d1 = parent.pospins[area.rope_id - 1].global_transform.origin.distance_squared_to(p)
		var d2 = parent.attachs[area.rope_id - 1].global_transform.origin.distance_squared_to(p)
		
		print("p = ", p)
		print("d1 = ", d1)
		print("d2 = ", d2)
		print("d1/d2 = ", d1/d2)
		print("(d1/d2) / 2  = ", (d1/d2) / 2)
		parent.cut_rope(area, (area.rope_id - 1), (d1/d2) / 2)
