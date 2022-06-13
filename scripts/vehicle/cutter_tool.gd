extends "res://scripts/vehicle/vehicle_tool.gd"
class_name CutterTool

var cutting: bool = false setget set_cutting
var current_area: Area
var last_cutted_area: Area

func try_cut() -> void:
	if not current_area or not cutting:
		return
	
	# Avoid running the code twice
	if current_area == last_cutted_area:
		return
	
	var parent = current_area.get_parent()
	if parent is NewFishingNet:
		parent.cut(current_area)
		last_cutted_area = current_area


func _ready() -> void:
	tool_type = Globals.ObjectiveType.CUTTER


func _on_RightCutArea_area_entered(area: Area) -> void:
	current_area = area


func _on_RightCutArea_area_exited(area: Area) -> void:
	current_area = null


func set_cutting(value: bool) -> void:
	if value:
		try_cut()
	cutting = value
