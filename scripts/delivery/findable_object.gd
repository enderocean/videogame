extends "res://scripts/delivery/delivery_object.gd"
class_name FindableObject

export var need_lights: bool = false

func _ready() -> void:
	objective_type = Globals.ObjectiveType.FIND
