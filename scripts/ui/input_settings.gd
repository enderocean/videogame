extends Control

export var input_select_path: NodePath
onready var input_select: InputSelect = get_node(input_select_path)


func _ready() -> void:
	var input_lines: Array = get_tree().get_nodes_in_group("input")
	for input_line in input_lines:
		input_line.connect("change_key", self, "_on_change_key", [input_line])
		input_line.connect("reset", self, "_on_reset_key", [input_line])
		
		# Load saved key bindings
		if SaveManager.settings.inputs.keyboard.has(input_line.action):
			set_action_key(input_line.action, SaveManager.settings.inputs.keyboard.get(input_line.action))
		
		input_line.update()


func _on_change_key(input_line: InputLine) -> void:
	if input_select.visible:
		return
	
	input_select.show()
	input_select.action = input_line.action
	# Listen for the key change
	yield(input_select, "key_changed")
	# Update UI
	input_line.update()
	input_select.hide()


func _on_reset_key(input_line: InputLine) -> void:
	set_action_key(input_line.action, SaveManager.default_settings.inputs.keyboard.get(input_line.action))
	input_line.update()


func set_action_key(action: String, scancode: int) -> void:
	# Start by removing previously key binding(s)
	for old_event in InputMap.get_action_list(action):
		# Only remove keyboard events
		if old_event is InputEventKey:
			InputMap.action_erase_event(action, old_event)

	var event: InputEventKey = InputEventKey.new()
	event.scancode = scancode
	event.pressed = true
	
	# Add the new key binding
	InputMap.action_add_event(action, event)
