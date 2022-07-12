extends Popup

export var normal_panel_path: NodePath
onready var normal_panel: Panel = get_node(normal_panel_path)

export var video_panel_path: NodePath
onready var video_panel: Panel = get_node(video_panel_path)

export var user_panel_path: NodePath
onready var user_panel: Panel = get_node(user_panel_path)

export var username_path: NodePath
onready var username: LineEdit = get_node(username_path)

var back_to_main_menu: bool = false setget set_back_to_main_menu


func _ready() -> void:
	video_panel.hide()


func play_video(path: String) -> void:
	video_panel.play(path)
	video_panel.show()


func update_stars(score: int, stars_enabled: bool) -> void:
	normal_panel.update_stars(score, stars_enabled)


func update_time(time: float) -> void:
	normal_panel.update_time(time)


func update_objectives(objectives: Dictionary, objectives_progress: Dictionary) -> void:
	normal_panel.update_objectives(objectives, objectives_progress)


func _on_visibility_changed() -> void:
	if not visible:
		return

	normal_panel.visible = false
	user_panel.visible = true
	username.editable = true
	video_panel.hide()


func _on_ok_pressed() -> void:
	username.editable = false

	var success: bool = check_username()
	if not success:
		username.editable = true
		return

	SaveManager.data.name = username.text
	if Globals.SEND_DATA:
#		Leaderboard.send_score()
		pass

	normal_panel.visible = true
	user_panel.visible = false


func check_username() -> bool:
	if " " in username.text:
		return false

	return true


func _on_restart_pressed() -> void:
	visible = false
	SceneLoader.reload_scenes()


func _on_back_pressed() -> void:
	visible = false
	
	if back_to_main_menu:
		SceneLoader.load_scene("res://scenes/ui/menu.tscn")
		return
	
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")


func set_back_to_main_menu(value: bool) -> void:
	back_to_main_menu = value
	if value:
		normal_panel.back_to_missions_button.key = "BACK_TO_MAIN_MENU"
		normal_panel.back_to_missions_button.update_text()
	else:
		normal_panel.back_to_missions_button.key = "BACK_TO_MISSION_MAP"
		normal_panel.back_to_missions_button.update_text()
