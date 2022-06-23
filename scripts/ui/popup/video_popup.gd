extends Popup
class_name VideoPopup

export var video_player_path: NodePath
var video_player: VideoPlayer

export var skip_progress_bar_path: NodePath
var skip_progress_bar: ProgressBar

export(float, 0.0, 10.0) var skip_time: float = 1.0
var skip_current_time: float = 0.0
var want_skip: bool = false


signal finished


func play(path: String) -> void:
	video_player.stream = load(path)
	video_player.play()
	
	want_skip = false
	skip_current_time = 0
	skip_progress_bar.visible = false


func skip() -> void:
	video_player.stop()
	_on_finished()


func _ready() -> void:
	video_player = get_node(video_player_path)
	skip_progress_bar = get_node(skip_progress_bar_path)
	set_process(false)


func _on_finished() -> void:
	hide()
	emit_signal("finished")


func _process(delta: float) -> void:
	# Skip timer
	skip_current_time += delta
	# Update progress bar
	skip_progress_bar.value = skip_current_time / skip_time
	# Skip the video when the time has been reached 
	if skip_current_time >= skip_time:
		skip()


func _input(event: InputEvent) -> void:
	if not video_player.is_playing():
		return
	
	# Skip video
	if (event is InputEventKey or event is InputEventJoypadButton or event is InputEventScreenTouch) and event.pressed:
		skip_progress_bar.visible = true
		set_process(true)
	else:
		set_process(false)
		skip_current_time = 0
		skip_progress_bar.visible = false
	
	get_tree().set_input_as_handled()
