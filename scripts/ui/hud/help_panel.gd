extends PanelContainer


func _input(event):
	if event.is_action_pressed("help"):
		if not is_visible():
			show()
		else:
			hide()
