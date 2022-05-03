extends "res://scripts/vehicle/vehicle_tool.gd"
class_name CutterTool

func _on_RightCutArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if (area.rope_id):
		var parent = area.get_parent()

		var node_point = get_node("CutRightRigidBody/RightCutArea")
		var d1 = parent.pospins[area.rope_id - 1].global_transform.origin.distance_squared_to(node_point.global_transform.origin)
		var d2 = parent.attachs[area.rope_id - 1].global_transform.origin.distance_squared_to(node_point.global_transform.origin)
	
		var cut_pos = d2 / (d1 + d2)
		parent.cut_rope(area, (area.rope_id - 1), cut_pos)

