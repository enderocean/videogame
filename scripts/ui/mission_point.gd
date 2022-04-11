extends Node2D
class_name MissionPoint

export var mission_id: String
export var zoom: Vector2 = Vector2(0.5, 0.5)
export var hover_color: Color = Color.white

var active: bool = false setget set_active

onready var sprite: Sprite = get_node("Sprite")
onready var normal_color: Color = sprite.self_modulate

signal pressed


func set_active(value: bool) -> void:
	active = value
	
	if active:
		sprite.self_modulate = hover_color
	else:
		sprite.self_modulate = normal_color


func _on_mouse_entered() -> void:
	if not active:
		sprite.self_modulate = hover_color


func _on_mouse_exited() -> void:
	if not active:
		sprite.self_modulate = normal_color


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("pressed", self)
