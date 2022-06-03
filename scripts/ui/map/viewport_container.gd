extends ViewportContainer

var viewport: Viewport

func _ready() -> void:
	viewport = get_child(0)


func _on_mouse_entered() -> void:
	viewport.gui_disable_input = false


func _on_mouse_exited() -> void:
	viewport.gui_disable_input = true
