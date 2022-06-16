extends Popup
class_name VideoPopup

export var video_player_path: NodePath
onready var video_player: VideoPlayer = get_node(video_player_path)

signal finished


func _on_finished() -> void:
	hide()
	emit_signal("finished")


func _input(event: InputEvent) -> void:
	if not video_player.is_playing():
		return
	
	# Pass video
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		video_player.stop()
		_on_finished()


func play(path: String) -> void:
	video_player.stream = load(path)
	video_player.play()
