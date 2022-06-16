extends Control


export var graphics_settings_path: NodePath
onready var graphics_settings = get_node(graphics_settings_path)
export var audio_settings_path: NodePath
onready var audio_settings = get_node(audio_settings_path)
export var inputs_settings_path: NodePath
onready var inputs_settings = get_node(inputs_settings_path)


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
