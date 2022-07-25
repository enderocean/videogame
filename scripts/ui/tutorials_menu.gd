extends Control

export var button_scene: PackedScene = preload("res://scenes/ui/tutorials/tutorial_button.tscn")

export var buttons_list_path: NodePath
var buttons_list: VBoxContainer


func _ready() -> void:
	buttons_list = get_node(buttons_list_path)
	
	var sa = 
	
	
	for i in Globals.tutorials.values().size():
		var button: Button = button_scene.instance()
		var level_data: LevelData = Globals.tutorials.values()[i]
		buttons_list.add_child(button)
		button.text = tr(level_data.id).to_upper()
		button.connect("pressed", self, "_on_button_pressed", [i])


func _on_button_pressed(index: int) -> void:
	SceneLoader.load_scene("res://scenes/ui/hud.tscn")
	SceneLoader.load_scene(Globals.tutorials.values()[index].scene, true)


func _on_back_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/menu.tscn")
