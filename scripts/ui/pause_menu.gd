extends Popup
class_name PauseMenu

export var settings_panel_path: NodePath
onready var settings_panel: SettingsPanel = get_node(settings_panel_path)

export var back_to_missions_path: NodePath
onready var back_to_missions_button: Button = get_node(back_to_missions_path)

var back_to_main_menu: bool = false


func _on_ReturnToGame_pressed() -> void:
	visible = false


func _on_Settings_pressed() -> void:
	settings_panel.visible = true


func _on_SettingsBack_pressed() -> void:
	settings_panel.visible = false


func _on_RestartMission_pressed() -> void:
	SceneLoader.reload_scenes()


func _on_BackToMap_pressed() -> void:
	var scene_path: String = "res://scenes/ui/missions.tscn"
	if back_to_main_menu:
		scene_path = "res://scenes/ui/menu.tscn"
	
	SceneLoader.load_scene(scene_path)


func _on_Ping360Toggle_toggled(button_pressed: bool) -> void:
	Globals.ping360_enabled = button_pressed


func _on_visibility_changed() -> void:
	var text: String = "BACK"
	
	if back_to_main_menu:
		text = tr("BACK_TO_MAIN_MENU")
	else:
		text = tr("BACK_TO_MISSIONS_MAP")
		
	if back_to_missions_button.uppercase:
		text = text.to_upper()
		
	back_to_missions_button.text = text
	
	settings_panel.visible = false
