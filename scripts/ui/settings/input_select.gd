extends Control
class_name InputSelect

export var already_used_path: NodePath
onready var already_used_label: Label = get_node(already_used_path)

var action: String setget set_action

signal key_changed(scancode)


func _input(event):
	if action.empty():
		return
	
	if event is InputEventKey:
		# Register the event as handled and stop polling
		get_tree().set_input_as_handled()
		set_process_input(false)
		
		# Get any key except the cancel action key (Escape)
		if not event.is_action("ui_cancel"):
			var scancode: String = OS.get_scancode_string(event.scancode)
			var already_used: Array = check_same_key(event.scancode)
			if already_used.size() > 0:
				already_used_label.text = "\"%s\" already used in:\n" % scancode
				for i in range(already_used.size()):
					already_used_label.text += already_used[i]
					if i < already_used.size() - 1:
						already_used_label.text += "\n"
				
				already_used_label.visible = true
				set_process_input(true)
				return
			
			already_used_label.visible = false
			
			# Start by removing previously key binding(s)
			for old_event in InputMap.get_action_list(action):
				# Only remove keyboard events
				if old_event is InputEventKey:
					InputMap.action_erase_event(action, old_event)
			
			# Add the new key binding
			InputMap.action_add_event(action, event)
			
			# Save the assigned key
			SaveManager.settings.inputs.keyboard[action] = event.scancode
			
			emit_signal("key_changed", scancode)
		else:
			set_process_input(false)
			hide()


func check_same_key(scancode: int) -> Array:
	var result: Array
	var actions: Array = InputMap.get_actions()
	for action in actions:
		# Ignore defaults for ui
		if action.begins_with("ui_"):
			continue
		
		var action_events: Array = InputMap.get_action_list(action)
		for event in action_events:
			if event is InputEventKey and event.scancode == scancode:
				result.append(action)
	return result


func set_action(value: String) -> void:
	action = value
	already_used_label.visible = false
	set_process_input(true)
