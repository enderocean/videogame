extends PanelContainer


func _input(event):
	if event.is_action_pressed("help"):
		if not is_visible():
			var help = get_child(0).get_node("help")
			print(help.text)
			help.text = tr(help.text)
			show()
		else:
			hide()
