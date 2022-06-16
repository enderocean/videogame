extends Control

export var graphics_settings_path: NodePath
export var audio_settings_path: NodePath
export var inputs_settings_path: NodePath
export var back_button_path: NodePath

onready var graphics_settings = get_node(graphics_settings_path)
onready var audio_settings = get_node(audio_settings_path)
onready var inputs_settings = get_node(inputs_settings_path)
onready var back_button: Button = get_node(back_button_path)


func _ready() -> void:
	inputs_settings.hide()
	audio_settings.hide()
	graphics_settings.show()


func _on_graphics_pressed() -> void:
	inputs_settings.hide()
	audio_settings.hide()
	graphics_settings.show()


func _on_audio_pressed() -> void:
	inputs_settings.hide()
	graphics_settings.hide()
	audio_settings.show()


func _on_inputs_pressed() -> void:
	graphics_settings.hide()
	audio_settings.hide()
	inputs_settings.show()


func _on_back_pressed() -> void:
	SaveManager.save_data()
	hide()
