extends Button
class_name InputEmitButton
# Simple class to use a button as an action emitter, useful for mobile

export var action: String


func _ready() -> void:
	connect("button_down", self, "_on_button_down")
	connect("button_up", self, "_on_button_up")
	
	if action.empty():
		printerr("No action defined for: ", name)


func _on_button_down() -> void:
	if action.empty():
		return
	
	Input.action_press(action, 1.0)


func _on_button_up() -> void:
	if action.empty():
		return
	
	Input.action_release(action)
