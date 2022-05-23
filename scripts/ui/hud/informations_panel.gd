extends Control
class_name InformationsPanel

export var compass_path: NodePath
onready var compass_texture: TextureRect = get_node(compass_path)

export var depth_value_path: NodePath
onready var depth_value: Label = get_node(depth_value_path)

export var tool_value_path: NodePath
onready var tool_value: Label = get_node(tool_value_path)

export(float, 0.0, 1.0) var speed_indicator_transparency: float = 0.5
export var speed_indicator_scene: PackedScene
export var speed_indicators_parent_path: NodePath
onready var speed_indicators_parent: Control = get_node(speed_indicators_parent_path)


func create_speed_indicators(count: int) -> void:
	for i in range(count):
		var indicator: ColorRect = speed_indicator_scene.instance()
		indicator.self_modulate.a = speed_indicator_transparency
		speed_indicators_parent.add_child(indicator)


func set_current_speed(index: int) -> void:
	for i in range(speed_indicators_parent.get_child_count()):
		var value: float = speed_indicator_transparency
		if i == index:
			value = 1.0
		print(i, ": ", value)
		speed_indicators_parent.get_child(i).self_modulate.a = value
