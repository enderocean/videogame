extends Control

export var master_slider_path: NodePath
var master_slider: SliderSetting
export var effects_slider_path: NodePath
var effects_slider: SliderSetting
export var radio_slider_path: NodePath
var radio_slider: SliderSetting
export var music_slider_path: NodePath
var music_slider: SliderSetting


func _ready() -> void:
	master_slider = get_node(master_slider_path)
	effects_slider = get_node(effects_slider_path)
	radio_slider = get_node(radio_slider_path)
	music_slider = get_node(music_slider_path)
	initialize_settings()


func _on_master_changed(value: float) -> void:
	SaveManager.settings.audio["master"] = set_volume("Master", value)


func _on_effects_changed(value: float) -> void:
	SaveManager.settings.audio["effects"] = set_volume("Effects", value)


func _on_radio_changed(value: float) -> void:
	SaveManager.settings.audio["radio"] = set_volume("Radio", value)


func _on_music_changed(value: float) -> void:
	SaveManager.settings.audio["music"] = set_volume("Music", value)


func initialize_settings() -> void:
	var default_audio_settings: Dictionary = SaveManager.default_settings.get("audio")
	var audio_settings: Dictionary = SaveManager.settings.get("audio")
	master_slider.value = audio_settings.get("master", default_audio_settings.get("master"))
	effects_slider.value = audio_settings.get("effects", default_audio_settings.get("effects"))
	radio_slider.value = audio_settings.get("radio", default_audio_settings.get("radio"))
	music_slider.value = audio_settings.get("music", default_audio_settings.get("music"))


func set_volume(bus_name: String, value: float) -> float:
	# Makes sure the value is between 0.0 and 1.0
	value = clamp(value, 0.0, 1.0)
	
	# Get the bus index"
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		print("Audio bus \"", bus_name, "\" not found.")
		return value
	
	# Set the volume of the wanted bus
	var volume_db: float = linear2db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	return value
