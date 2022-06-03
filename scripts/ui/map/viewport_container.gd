extends ViewportContainer

var viewport: Viewport

func _ready() -> void:
	viewport = get_child(0)
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_entered() -> void:
	viewport.set_process_input(true)
	viewport.gui_disable_input = false


func _on_mouse_exited() -> void:
	viewport.set_process_input(false)
	viewport.gui_disable_input = true
