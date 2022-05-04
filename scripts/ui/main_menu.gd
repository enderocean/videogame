extends Control

export var licences_popup_path: NodePath
onready var licences_popup: AcceptDialog = get_node(licences_popup_path)
onready var playback_position: float
export var level_buttons_path: NodePath

var icon_music = preload("res://assets/music.png")
var icon_music_off = preload("res://assets/music_off.png")


func create_level_buttons(levels: Array) -> void:
	for level in levels:
		var button = Button.new()
		button.text = level.title
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
		get_node("Music").set_button_icon(icon_music_off)
		playback_position = audio_stream_player.get_playback_position()
	else:
		audio_stream_player.play(playback_position)
		get_node("Music").set_button_icon(icon_music)
