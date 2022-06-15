extends Control

const ICON_MUSIC = preload("res://assets/music.png")
const ICON_MUSIC_OFF = preload("res://assets/music_off.png")

export var music_icon_path: NodePath
onready var music_icon_texture: TextureRect = get_node(music_icon_path)

export var licences_popup_path: NodePath
onready var licences_popup: AcceptDialog = get_node(licences_popup_path)

export var level_buttons_path: NodePath

export var settings_path: NodePath
onready var settings: Control = get_node(settings_path)

var playback_position: float


func create_level_buttons(levels: Array) -> void:
	for level in levels:
		var button = Button.new()
		button.text = level.title
	# warning-ignore:return_value_discarded
		button.connect("pressed", self, "_on_level_pressed", [level.scene])
		get_node(level_buttons_path).add_child(button)


func find_external_levels():
	var levels = LevelLoader.list_available_external_levels()
	create_level_buttons(levels)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	find_external_levels()
	pass


func _on_CheckBox_toggled(button_pressed):
	Globals.wait_SITL = button_pressed


func _on_licences_pressed():
	licences_popup.show()


func _on_Practice_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/hud.tscn")
	SceneLoader.load_scene("res://scenes/practice.tscn", true)


func _on_Campaign_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")


func _on_Music_pressed():
	var audio_stream_player = get_node("AudioStreamPlayer")
	if audio_stream_player.is_playing():
		audio_stream_player.stop()
		music_icon_texture.texture = ICON_MUSIC_OFF
		playback_position = audio_stream_player.get_playback_position()
	else:
		audio_stream_player.play(playback_position)
		music_icon_texture.texture = ICON_MUSIC


func _on_book_session_pressed() -> void:
	OS.shell_open(Globals.LINKS.get("events"))


func _on_show_events_pressed():
	OS.shell_open(Globals.LINKS.get("events"))


func _on_Introduction_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/introduction.tscn")


func _on_Back_pressed():
	SceneLoader.load_scene("res://scenes/ui/menu.tscn")


func _on_Close_pressed():
	get_tree().quit()


func _on_settings_pressed() -> void:
	settings.show()
