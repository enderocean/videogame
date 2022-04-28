extends Popup

const objective_line: PackedScene = preload("res://scenes/ui/objective_line.tscn")

export var title_label_path: NodePath
onready var title_label: Label = get_node(title_label_path)

export var time_label_path: NodePath
onready var time_label: Label = get_node(time_label_path)

export var objectives_list_path: NodePath
onready var objectives_list: VBoxContainer = get_node(objectives_list_path)

export var normal_panel_path: NodePath
onready var normal_panel: Panel = get_node(normal_panel_path)

export var user_panel_path: NodePath
onready var user_panel: Panel = get_node(user_panel_path)

export var username_path: NodePath
onready var username: LineEdit = get_node(username_path)


func update_time(time: float) -> void:
	time_label.text = MissionTimer.format_time(time)


func update_objectives(objectives: Dictionary) -> void:
	if objectives.size() == 0:
		return

	for i in range(objectives.keys().size()):
		# Try to get existing line
		var line: ObjectiveLine = null
		if i < objectives_list.get_child_count():
			line = objectives_list.get_child(i)

		# Create new line
		if not line:
			line = objective_line.instance()
			objectives_list.add_child(line)

		line.title.text = Localization.get_objective_text(objectives.keys()[i])
		line.value.text = str(objectives.values()[i])


func _on_visibility_changed() -> void:
	if not visible:
		return

	normal_panel.visible = false
	user_panel.visible = true
	username.editable = true


func _on_Ok_pressed() -> void:
	username.editable = false

	var success: bool = check_username()
	if not success:
		username.editable = true
		return

	SaveManager.data.name = username.text
	if Globals.SEND_DATA:
		Leaderboard.send_score()

	normal_panel.visible = true
	user_panel.visible = false


func check_username() -> bool:
	if " " in username.text:
		return false

	return true


func _on_Restart_pressed() -> void:
	visible = false
	SceneLoader.reload_scenes()


func _on_Back_pressed() -> void:
	visible = false
	SceneLoader.load_scene("res://scenes/ui/menu.tscn")
