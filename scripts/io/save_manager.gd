extends Node

const SAVE_FILE: String = "user://save"

var tutorials: Dictionary = {}
var levels: Dictionary = {}
var collectibles: Dictionary = {}
var settings: Dictionary = {}

var default_settings: Dictionary = {
		"graphics": {
			"fullscreen": true,
			"vsync": ProjectSettings.get_setting("display/window/vsync/use_vsync"),
			"physics_rate": ProjectSettings.get_setting("physics/common/physics_fps"),
			"fancy_water": true
		},
		"audio": {
			"master": 1.0,
			"music": 1.0,
			"effects": 1.0,
			"radio": 1.0
		},
		"inputs": {
			"keyboard": {},
		}
	}


func _ready() -> void:
	default_settings.inputs["keyboard"] = get_default_inputs()
	settings = default_settings
	load_data()


func load_data() -> void:
	var file: File = File.new()
	if not file.file_exists(SAVE_FILE):
		return

	var error: int = file.open(SAVE_FILE, File.READ)
	if error != OK:
		printerr("Error while opening file to load save.")
		return

	var data: Dictionary = file.get_var(true)
	levels = data.get("levels", levels)
	collectibles = data.get("collectibles", collectibles)
	settings = data.get("settings", settings)
	file.close()
	print("Loaded data from ", ProjectSettings.globalize_path(SAVE_FILE))


func save_data() -> void:
	var file = File.new()
	var error: int = file.open(SAVE_FILE, File.WRITE)
	if error != OK:
		printerr("Error while opening file to save data.")
		return
	
	var data: Dictionary = {}
	data["tutorials"] = tutorials
	data["levels"] = levels
	data["collectibles"] = collectibles
	data["settings"] = settings
	
	file.store_var(data, true)
	file.close()
	print("Saved data in ", ProjectSettings.globalize_path(SAVE_FILE))


func get_default_inputs() -> Dictionary:
	var default_inputs: Dictionary
	var actions: Array = InputMap.get_actions()
	for action in actions:
		# Ignore "unused" actions
		if action.begins_with("ui_"):
			continue
		
		var input_events: Array = InputMap.get_action_list(action)
		for input_event in input_events:
			if input_event is InputEventKey:
				default_inputs[action] = input_event.scancode
	return default_inputs
