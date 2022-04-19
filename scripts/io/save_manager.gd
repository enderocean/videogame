extends Node

const SAVE_FILE: String = "user://save"

var data: Dictionary = {"name": "", "levels": {}}


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

	data = file.get_var(true)
	file.close()
	print("Loaded data from ", SAVE_FILE)


func save_data() -> void:
	var file = File.new()
	var error: int = file.open(SAVE_FILE, File.WRITE)
	if error != OK:
		printerr("Error while opening file to save data.")
		return

	file.store_var(data, true)
	file.close()
	print("Saved data in ", SAVE_FILE)
