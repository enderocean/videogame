extends Node

const SAVE_FILE: String = "user://save"

var levels: Dictionary = {}
var collectibles: Dictionary = {}
var settings: Dictionary = {
		"graphics": {
			"physics_rate": 60,
			"fancy_water": true
		},
		"audio": {
			"master": 1.0,
			"radio": 1.0
		},
		"inputs": {
			"keyboard": {}
		}
	}


func _ready() -> void:
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
	data["levels"] = levels
	data["collectibles"] = collectibles
	data["settings"] = settings
	
	file.store_var(data, true)
	file.close()
	print("Saved data in ", ProjectSettings.globalize_path(SAVE_FILE))


