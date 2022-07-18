extends Control

export var username_field_path: NodePath
onready var username_field: LineEdit = get_node(username_field_path)
export var password_field_path: NodePath
onready var password_field: LineEdit = get_node(password_field_path)

var regex: RegEx = RegEx.new()

func clean_text(text: String) -> String:
	regex.compile("/^[a-zA-Z0-9]+$/")
	return text


func _on_login_pressed() -> void:
	var username: String = clean_text(username_field.text)
	var password: String = clean_text(password_field.text)
	APIManager.request_auth(username, password)
	yield(APIManager, "auth_completed")
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")


func _on_continue_without_login_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")

