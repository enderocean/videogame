extends Control


export var fullscreen_toggle_path: NodePath
export var vsync_toggle_path: NodePath
export var fancy_water_toggle_path: NodePath
export var physics_rate_slider_path: NodePath

var fullscreen_toggle: ToggleSetting
var vsync_toggle: ToggleSetting
var fancy_water_toggle: ToggleSetting
var physics_rate_slider: SliderSetting


func _ready() -> void:
	fullscreen_toggle = get_node(fullscreen_toggle_path)
	vsync_toggle = get_node(vsync_toggle_path)
	fancy_water_toggle = get_node(fancy_water_toggle_path)
	physics_rate_slider = get_node(physics_rate_slider_path)
	
	fullscreen_toggle.enabled = SaveManager.settings.graphics.get("fullscreen")
	vsync_toggle.enabled = SaveManager.settings.graphics.get("vsync")
	fancy_water_toggle.enabled = SaveManager.settings.graphics.get("fancy_water")
	physics_rate_slider.value = SaveManager.settings.graphics.get("physics_rate")


func _on_fullscreen_changed(value: bool) -> void:
	OS.window_fullscreen = value
	SaveManager.settings.graphics["fullscreen"] = value


func _on_vsync_changed(value: bool) -> void:
	OS.vsync_enabled = value
	SaveManager.settings.graphics["vsync"] = value


func _on_fancy_water_changed(value: bool) -> void:
	Globals.fancy_water = value
	SaveManager.settings.graphics["fancy_water"] = value


func _on_physics_rate_changed(value) -> void:
	Globals.physics_rate = value
	SaveManager.settings.graphics["physics_rate"] = value
