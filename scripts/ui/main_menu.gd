extends Control

export var licences_popup_path: NodePath
onready var licences_popup: AcceptDialog = get_node(licences_popup_path)

func create_level_buttons(levels):
	for filename in levels.keys():
		var button = Button.new()
		button.text = levels[filename]
		button.add_font_override("font", $HBoxContainer/Menu/Buttons/poolLevel.get_font("font"))
		button.connect("pressed", self, "_on_customLevel_pressed", [filename])
		$HBoxContainer/Menu/Buttons.add_child(button)

func find_external_levels():
	var levels = LevelLoader.list_available_external_levels()
	create_level_buttons(levels)

# Called when the node enters the scene tree for the first time.
func _ready():
	find_external_levels()

func _on_poolLevel_pressed():
	Globals.active_vehicle = "bluerovheavy"
	Globals.active_level = "res://scenes/pool.tscn"
	SceneLoader.goto_scene("res://scenes/baselevel.tscn")

func _on_CheckBox_toggled(button_pressed):
	Globals.wait_SITL = button_pressed

# func _on_customLevel_pressed(filename):
# 	Globals.active_vehicle = "bluerovheavy"
# 	Globals.active_level = "res://custom_level.tscn"
# 	ProjectSettings.load_resource_pack("res://levels/" + filename)
# 	SceneLoader.goto_scene("res://levels/baselevel.tscn")

func _on_customLevel_pressed():
	Globals.active_vehicle = "bluerovheavy"
	Globals.active_level = "res://scenes/demo_level.tscn"
	var loaded: bool = ProjectSettings.load_resource_pack("res://levels/%s" % filename)
	if not loaded:
		print("Error while loading resource pack: %s", filename)
	SceneLoader.goto_scene("res://scenes/baselevel.tscn")

func _on_level_01_pressed():
	Globals.active_vehicle = "bluerovheavy"
	Globals.active_level = "res://scenes/level_01.tscn"
	var loaded: bool = ProjectSettings.load_resource_pack("res://levels/%s" % filename)
	if not loaded:
		print("Error while loading resource pack: %s", filename)
	SceneLoader.goto_scene("res://scenes/baselevel.tscn")

func _on_licences_pressed():
	licences_popup.show()
