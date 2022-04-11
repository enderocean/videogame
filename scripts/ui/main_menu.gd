extends Control

export var licences_popup_path: NodePath
onready var licences_popup: AcceptDialog = get_node(licences_popup_path)

export var level_buttons_path: NodePath

func create_level_buttons(levels: Array) -> void:
	for level in levels:
		var button = Button.new()
		button.text = level.title
		button.connect("pressed", self, "_on_level_pressed",[level.scene])
		get_node(level_buttons_path).add_child(button)

func find_external_levels():
	var levels = LevelLoader.list_available_external_levels()
	create_level_buttons(levels)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Levels: ", Globals.levels.size())
	create_level_buttons(Globals.levels)
#	find_external_levels()

func _on_poolLevel_pressed() -> void:
	Globals.active_vehicle = "bluerovheavy"
	SceneLoader.load_scene("res://scenes/hud.tscn")
	SceneLoader.load_scene("res://scenes/practice.tscn", true)

func _on_level_pressed(scene_path: String) -> void:
	Globals.active_vehicle = "bluerovheavy"
	SceneLoader.load_scene("res://scenes/hud.tscn")
	SceneLoader.load_scene(scene_path, true)

func _on_CheckBox_toggled(button_pressed):
	Globals.wait_SITL = button_pressed

# func _on_customLevel_pressed(filename):
# 	Globals.active_vehicle = "bluerovheavy"
# 	Globals.active_level = "res://custom_level.tscn"
# 	var loaded: bool = ProjectSettings.load_resource_pack("res://levels/%s" % filename)
# 	if not loaded:
# 		print("Error while loading resource pack: %s", filename)
# 	SceneLoader.goto_scene("res://scenes/baselevel.tscn")

func _on_licences_pressed():
	licences_popup.show()
