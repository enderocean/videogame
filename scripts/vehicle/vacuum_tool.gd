extends "res://scripts/vehicle/vehicle_tool.gd"
class_name VacuumTool

var area_bodys = []
var removed_bodys = []

func _ready() -> void:
	
	get_node("VacuumRigidBody/VaccumProcess").connect("objects_changed", self, "_on_Vaccum_objects_changed")

func _on_Vaccum_objects_changed(objects: Array) -> void:
	for id in objects.size():
		if (removed_bodys.find(objects[id]) == -1):
			removed_bodys.append(objects[id])
			instance_from_id(objects[id]).queue_free()

	print(removed_bodys.size())
		
