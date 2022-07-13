extends Node
class_name InputObjective

export var action_name: String
export var on_released: bool = false

signal completed()


func _ready() -> void:
	add_to_group("objectives_nodes")


func _input(event: InputEvent) -> void:
	if on_released:
		if event.is_action_released(action_name):
			emit_signal("completed")
	else:
		if event.is_action_pressed(action_name):
			emit_signal("completed")
