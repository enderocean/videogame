extends "res://scripts/ui/settings/setting_line.gd"
class_name SliderSetting

# Use the value of the slider instead of a range from 0.0 to 1.0
# You must modify the slider directly to set it's values
export var use_value: bool = false
export var value_suffix: String = ""

export var slider_path: NodePath
var slider: Slider
export var value_label_path: NodePath
var value_label: Label

# Must be between 0.0 and 1.0
var value: float setget set_value

func _ready() -> void:
	slider = get_node(slider_path)
	value_label = get_node(value_label_path)


func set_value(new_value: float) -> void:
	value = new_value
	slider.value = new_value
	if use_value:
		value_label.text = "%s %s" % [slider.value, value_suffix]
	else:
		value_label.text = str(slider.value * 100) + " %"
	emit_signal("changed", value)


func _on_value_changed(new_value: float) -> void:
	set_value(new_value)
