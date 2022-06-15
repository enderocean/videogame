extends HBoxContainer
class_name SettingLine

export var setting_key: String

export var label_path: NodePath
var label: Label

signal changed(value)


func _ready() -> void:
	label = get_node(label_path)
	label.text = Localization.get_setting_text(setting_key)
