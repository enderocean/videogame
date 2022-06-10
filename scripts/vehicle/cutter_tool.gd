extends "res://scripts/vehicle/vehicle_tool.gd"
class_name CutterTool

var cuting: bool = false

func _ready() -> void:
	tool_type = Globals.ObjectiveType.CUTTER


func _on_RightCutArea_area_entered(area: Area) -> void:
	if not cuting:
		return
	
	var parent = area.get_parent()
	if parent is NewFishingNet:
		parent.cut(area)
