extends Control

export var username_field_path: NodePath
onready var username_field: LineEdit = get_node(username_field_path)
export var password_field_path: NodePath
onready var password_field: LineEdit = get_node(password_field_path)
export var connect_button_path: NodePath
onready var connect_button: Button = get_node(connect_button_path)
export var error_popup_path: NodePath
onready var error_popup: Popup = get_node(error_popup_path)
export var error_label_path: NodePath
onready var error_label: Label = get_node(error_label_path)

var regex: RegEx = RegEx.new()

func clean_text(text: String) -> String:
	regex.compile("/^[a-zA-Z0-9]+$/")
	return text


func show_error(message: String) -> void:
	error_label.text = message
	error_popup.show()


func goto_missions() -> void:
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")


func _ready() -> void:
	APIManager.connect("auth_success", self, "_on_auth_success")
	APIManager.connect("auth_failed", self, "_on_auth_failed")


func _on_login_pressed() -> void:
	var username: String = clean_text(username_field.text)
	var password: String = clean_text(password_field.text)
	
	if username.empty() or password.empty():
		show_error(tr("USERNAME_OR_PASSWORD_EMPTY"))
		return
	
	connect_button.disabled = true
	APIManager.request_auth(username, password)


func _on_continue_without_login_pressed() -> void:
	goto_missions()


func _on_auth_success() -> void:
	goto_missions()


func _on_auth_failed(error: String) -> void:
	connect_button.disabled = false
	if error.empty():
		show_error(tr("ERROR_SOMETHING_WRONG_HAPPENED"))
		printerr("No specific error was given.");
		return
	
	if error == "INVALID_USERNAME" or error == "INVALID_PASSWORD":
		show_error(tr("ERROR_INVALID_CREDENTIALS"))
	else:
		show_error(tr(error))
	
	# Show the error in the console for debugging
	printerr(error);
	


func _on_ok_pressed() -> void:
	error_popup.hide()
	error_label.text = ""
