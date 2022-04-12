extends Node2D
class_name MissionPoint

export var mission_id: String
export var completed: bool = false
export var zoom: Vector2 = Vector2(0.5, 0.5)

var active: bool = false setget set_active

onready var active_sprite: Sprite = get_node("Normal/Active")

signal pressed


func set_active(value: bool) -> void:
	active = value
	active_sprite.visible = active


func _on_mouse_entered() -> void:
	if not active:
		active_sprite.visible = true


func _on_mouse_exited() -> void:
	if not active:
		active_sprite.visible = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("pressed", self)
