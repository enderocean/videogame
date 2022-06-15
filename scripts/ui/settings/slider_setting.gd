extends "res://scripts/ui/settings/setting_line.gd"
class_name SliderSetting

export var slider_path: NodePath
var slider: Slider

var value: float setget set_value

func _ready() -> void:
	slider = get_node(slider_path)
	label.text = Localization.get_setting_text(setting_key)


func set_value(new_value: float) -> void:
	value = new_value
	slider.value = new_value
	emit_signal("changed", value)


func _on_value_changed(new_value: float) -> void:
	value = new_value
