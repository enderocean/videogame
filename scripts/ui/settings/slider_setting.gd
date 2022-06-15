extends "res://scripts/ui/settings/setting_line.gd"
class_name SliderSetting

export var slider_path: NodePath
var slider: Slider
export var value_label_path: NodePath
var value_label: Label

# Must be between 0.0 and 1.0
var value: float setget set_value

func _ready() -> void:
	slider = get_node(slider_path)
	value_label = get_node(value_label_path)
	label.text = Localization.get_setting_text(setting_key)


func set_value(new_value: float) -> void:
	value = new_value
	slider.value = new_value
	value_label.text = str(slider.value * 100) + " %"
	emit_signal("changed", value)


func _on_value_changed(new_value: float) -> void:
	set_value(new_value)
