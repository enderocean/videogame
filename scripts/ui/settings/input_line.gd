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
		return
	
	add_to_group("input")
	input_button.connect("pressed", self, "_on_input_button_pressed")
	update()


func _on_input_button_pressed() -> void:
	if not has_valid_action:
		return
	
	emit_signal("change_key")


func update() -> void:
	if not has_valid_action:
		return
	
	label.text = action
	var actions: Array = InputMap.get_action_list(action)
	
	for action in actions:
		if action is InputEventKey:
			input_button.text = OS.get_scancode_string(action.scancode)
			break

