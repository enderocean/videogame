extends Node

onready var bin_path: String = OS.get_executable_path().get_base_dir()

func _ready() -> void:
	ensure_levels_folder_exists()

func ensure_levels_folder_exists() -> void:
	var directory = Directory.new();
	directory.open(bin_path)
	directory.make_dir("levels")

func list_available_external_levels():
	var dir = Directory.new()
	dir.open(bin_path + "/levels")
	print("Looking for additional levels at %s" % bin_path + "/levels")
	dir.list_dir_begin()
	var found = []

	# list .pck files
	while true:
		var file = dir.get_next()
		if file.empty():
			break
		elif not file.begins_with(".") and file.ends_with(".pck"):
			found.append(file)
	dir.list_dir_end()
	
	# validate .pck files
	# They must have a custom_level.tscn file
	var valid = {}
	for file in found:
		if not ProjectSettings.load_resource_pack("res://levels/" + file):
			print("Failed to load file: " + file)
		# Now one can use the assets as if they had them in the project from the start
		var imported_scene = load("res://custom_level.tscn")
		if imported_scene == null:
			print("Unable to find 'custom_level.tscn' in file " + file)
			continue
		var level_name = file
		valid[file] = level_name
	return valid
