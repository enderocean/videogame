extends Resource
class_name LevelData

export var id: String = "level_id"
export(String, FILE, "*.tscn") var scene: String
export(String, FILE, "*.jpg, *.png") var thumbnail: String
export(String, FILE) var video: String

export var title: String = ""
export var country: String = ""
export var location: String = ""
export(String, MULTILINE) var description: String = ""
export var objectives: PoolStringArray
export var tools: PoolStringArray

# Time in minutes
export var time: int = 15

# For each objectives count vars, if it's value is 0, it will look for Delivery objects in the level instead with an ObjectiveTag instead
# This gives more freedom on doing different approach for the same type of objective
export var gripper_objectives_count: int = 0
export var vacuum_objectives_count: int = 0
export var cutter_objectives_count: int = 0

export var stars_enabled: bool = true
# Must be an array of 5 intergers, which indicates the time elapsed in seconds for each stars
# e.g. The player needs to complete the level in 60 seconds to have 5 stars (without any penalities)
export var stars: PoolIntArray = [900, 600, 300, 180, 60]

# TODO: Get the translation in the UI code instead
#func _ready() -> void:
#	# Apply translations
#	title = tr(title)
#	country = tr(country)
#	location = tr(location)
#	description = tr(description)
#
#	for i in range(objectives.size()):
#		objectives[i] = tr(objectives[i])
#
#	for i in range(tools.size()):
#		tools[i] = tr(tools[i])


static func get_levels(path: String) -> Dictionary:
	if not Globals.is_valid_directory_path(path):
		printerr("The given path is not valid")
		return {}
	
	var files: PoolStringArray = Globals.get_files(path)
	var levels: Dictionary = {}
	var file: File = File.new()

	for file_name in files:
		if not file.file_exists(path + file_name):
			continue

		var level: LevelData = load(path + file_name)
		if not level:
			continue

		if not levels.has(level.id):
			levels[level.id] = level

	return levels
