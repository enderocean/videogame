extends Control

export var input_select_path: NodePath
onready var input_select: InputSelect = get_node(input_select_path)

func _ready() -> void:
	var input_lines: Array = get_tree().get_nodes_in_group("input")
	for input_line in input_lines:
		input_line.connect("change_key", self, "_on_change_key", [input_line])


func _on_change_key(input_line: InputLine) -> void:
	if input_select.visible:
		return
	
	input_select.show()
	print("change on ", input_line.action)
	input_select.action = input_line.action
	# Listen for the key change
	var scancode: String = yield(input_select, "key_changed")
	# Update UI
	input_line.update()
	input_select.hide()
