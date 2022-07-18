extends HBoxContainer
class_name InputLine

export var action: String = ""

onready var label: Label = get_node("Label")
onready var input_button: Button = get_node("Input")
onready var reset_button: Button = get_node("Reset")

var has_valid_action: bool

signal change_key()
signal reset()


func _ready() -> void:
	has_valid_action = InputMap.has_action(action)
	if not has_valid_action:
		printerr("No valid action for input line: ", name)
		return
	
	add_to_group("input")
	update()


func _on_input_button_pressed() -> void:
	if not has_valid_action:
		return
	
	emit_signal("change_key")


func _on_reset_button_pressed() -> void:
	emit_signal("reset")


func update() -> void:
	if not has_valid_action:
		return
	
	var input_events: Array = InputMap.get_action_list(action)
	for input_event in input_events:
		if input_event is InputEventKey:
			reset_button.disabled = input_event.scancode == SaveManager.default_settings.inputs.keyboard.get(action)
			input_button.text = OS.get_scancode_string(input_event.scancode)
			break
