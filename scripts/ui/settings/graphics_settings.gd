extends Control


func _ready() -> void:
	_on_fullscreen_changed(SaveManager.settings.graphics.get("fullscreen"))
	_on_vsync_changed(SaveManager.settings.graphics.get("vsync"))
	_on_fancywater_changed(SaveManager.settings.graphics.get("fancy_water"))


func _on_fullscreen_changed(value: bool) -> void:
	OS.window_fullscreen = value
	SaveManager.settings.graphics["fullscreen"] = value


func _on_vsync_changed(value: bool) -> void:
	OS.vsync_enabled = value
	SaveManager.settings.graphics["vsync"] = value


func _on_fancywater_changed(value: bool) -> void:
	Globals.fancy_water = value
	SaveManager.settings.graphics["fancy_water"] = value
