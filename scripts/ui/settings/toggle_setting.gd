extends "res://scripts/ui/settings/setting_line.gd"
class_name ToggleSetting

export var check_button_path: NodePath
var check_button: CheckButton

var enabled: bool setget set_enabled

func _ready() -> void:
	check_button = get_node(check_button_path)


func set_enabled(value: bool) -> void:
	enabled = value
	check_button.pressed = value
	emit_signal("changed", enabled)


func _on_toggled(button_pressed: bool) -> void:
	enabled = button_pressed
