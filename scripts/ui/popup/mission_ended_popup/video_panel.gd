extends Panel

export var video_player_path: NodePath
onready var video_player: VideoPlayer = get_node(video_player_path)


func play(path: String) -> void:
	video_player.stream = load(path)
	video_player.play()
