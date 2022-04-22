extends "res://scripts/vehicle/vehicle_tool.gd"
class_name VacuumTool

var area_bodys = []

func _ready() -> void:
	
	get_node("VaccumProcess").connect("objects_changed", self, "_on_Vaccum_objects_changed")

func _on_Vaccum_objects_changed(objects: Array) -> void:
	pass
