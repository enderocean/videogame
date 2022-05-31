extends Control
class_name InformationsPanel

export var compass_path: NodePath
onready var compass_texture: TextureRect = get_node(compass_path)

export var depth_value_path: NodePath
onready var depth_value: Label = get_node(depth_value_path)

export var tool_value_path: NodePath
onready var tool_value: Label = get_node(tool_value_path)

export var speed_indicator_color_off: Color
export var speed_indicator_color_on: Color

#export(float, 0.0, 1.0) var speed_indicator_transparency: float = 0.5
export var speed_indicator_scene: PackedScene
export var speed_indicators_parent_path: NodePath
onready var speed_indicators_parent: Control = get_node(speed_indicators_parent_path)


func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_on_screen_resized()


func create_speed_indicators(count: int) -> void:
	for i in range(count):
		var indicator: ColorRect = speed_indicator_scene.instance()
		indicator.self_modulate = speed_indicator_color_off
		speed_indicators_parent.add_child(indicator)


func set_current_speed(index: int) -> void:
	for i in range(speed_indicators_parent.get_child_count()):
		var value: Color = speed_indicator_color_on
		if i > index:
			value = speed_indicator_color_off
		speed_indicators_parent.get_child(i).self_modulate = value


func _on_screen_resized() -> void:
	compass_texture.rect_pivot_offset = compass_texture.rect_size / 2
