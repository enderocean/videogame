extends Resource
class_name LevelData

export var id: String = "level_id"
export(String, FILE, "*.tscn") var scene: String
export(String, FILE, "*.jpg, *.png") var thumbnail: String

export var title: String = ""
export var country: String = ""
export var location: String = ""
export(String, MULTILINE) var description: String = ""

# Time in minutes
export var time: int = 15
export var objectives: PoolStringArray
export var tools: PoolStringArray

export var stars_enabled: bool = true
# Must be an array of 5 intergers, which indicates the time elapsed in seconds for each stars
# e.g. The player needs to complete the level in 60 seconds to have 5 stars (without any penalities)
export var stars: PoolIntArray = [900, 600, 300, 180, 60]

static func get_levels() -> Dictionary:
	var path: String = "res://assets/levels/"
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
