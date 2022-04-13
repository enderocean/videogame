extends Node2D
class_name MissionPoint

export var mission_id: String
export var completed: bool = false
export var zoom: Vector2 = Vector2(0.5, 0.5)

export var active_color: Color = Color.green
export var completed_color: Color = Color("#3684de")

onready var normal_sprite: Sprite = get_node("Normal")
onready var active_sprite: Sprite = get_node("Normal/Active")
onready var normal_sprite_color: Color = normal_sprite.self_modulate

var active: bool = false setget set_active

signal pressed


func update_color() -> void:
	if active:
		normal_sprite.self_modulate = active_color
	elif completed:
		normal_sprite.self_modulate = completed_color
	else:
		normal_sprite.self_modulate = normal_sprite_color


func set_active(value: bool) -> void:
	active = value
	active_sprite.visible = active
	update_color()


func _on_mouse_entered() -> void:
	active_sprite.visible = true
	update_color()


func _on_mouse_exited() -> void:
	active_sprite.visible = false
	update_color()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("pressed", self)
