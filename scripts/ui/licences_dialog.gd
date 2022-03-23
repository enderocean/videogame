extends AcceptDialog

func _on_meta_clicked(meta) -> void:
	var error = OS.shell_open(str(meta))
	if error != OK:
		print("Error: %s" % error)
