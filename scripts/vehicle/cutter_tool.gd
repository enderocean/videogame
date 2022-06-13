extends "res://scripts/vehicle/vehicle_tool.gd"
class_name CutterTool

var cuting: bool = false
var last_cutted_area: Area

func try_cut(area: Area) -> void:
	if not area or not cuting:
		return
	
	# Avoid running the code twice
	if area == last_cutted_area:
		return
	
	var parent = area.get_parent()
	if parent is NewFishingNet:
		parent.cut(area)
		last_cutted_area = area


func _ready() -> void:
	tool_type = Globals.ObjectiveType.CUTTER


func _on_RightCutArea_area_entered(area: Area) -> void:
	try_cut(area)


func _on_RightCutArea_area_exited(area: Area) -> void:
	try_cut(area)
