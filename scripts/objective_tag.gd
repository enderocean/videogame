extends Node
class_name ObjectiveTag
# Used to tag a specific object as an objective
# Which can be useful for certain types of objectives
# Of course it needs to be a supported type

# Specific text to objective
export var text_key: String

func _ready() -> void:
	add_to_group("objective_tags")
