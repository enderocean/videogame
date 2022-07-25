extends Control

export var button_scene: PackedScene = preload("res://scenes/ui/tutorials/tutorial_button.tscn")

export var buttons_list_path: NodePath

var buttons_list: VBoxContainer
var sorted_tutorials_id: Array

func _ready() -> void:
	buttons_list = get_node(buttons_list_path)
	
	# Sort tutorials by id
	sorted_tutorials_id = Globals.tutorials.keys()
	sorted_tutorials_id.sort()
	
	# Create tutorials button
	for i in range(sorted_tutorials_id.size()):
		var tutorial_id: String = sorted_tutorials_id[i]
		var button: Button = button_scene.instance()
		var level_data: LevelData = Globals.tutorials.get(tutorial_id)
		buttons_list.add_child(button)
		button.text = tr(level_data.id).to_upper()
		button.connect("pressed", self, "_on_button_pressed", [i])


func _on_button_pressed(index: int) -> void:
	SceneLoader.load_scene("res://scenes/ui/hud.tscn")
	SceneLoader.load_scene(Globals.tutorials.get(sorted_tutorials_id[index]).scene, true)


func _on_back_pressed() -> void:
	SceneLoader.load_scene("res://scenes/ui/menu.tscn")
