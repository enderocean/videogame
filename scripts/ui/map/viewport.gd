extends Viewport

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		unhandled_input(event)
