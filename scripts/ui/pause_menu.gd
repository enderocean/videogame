extends Popup
class_name PauseMenu

export var settings_panel_path: NodePath
onready var settings_panel: SettingsPanel = get_node(settings_panel_path)


func _on_ReturnToGame_pressed() -> void:
	visible = false


func _on_Settings_pressed() -> void:
	settings_panel.visible = true


func _on_SettingsBack_pressed() -> void:
	settings_panel.visible = false


func _on_RestartMission_pressed() -> void:
	SceneLoader.reload_scenes()


func _on_BackToMap_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/missions.tscn")


func _on_Ping360Toggle_toggled(button_pressed: bool) -> void:
	Globals.ping360_enabled = button_pressed


func _on_visibility_changed() -> void:
	settings_panel.visible = false
