extends Resource
class_name LevelData

export var id: String = "level_id" 
export(String, FILE, "*.tscn") var scene: String
export(String, FILE, "*.jpg, *.png") var thumbnail: String

export var title: String = ""
export var country: String = ""
export var location: String = ""
export(String, MULTILINE) var description: String = ""

export var objectives: PoolStringArray
export var tools: PoolStringArray


static func get_levels() -> Dictionary:
	var path: String = "res://assets/levels/"
	var files: PoolStringArray = get_files("res://assets/levels/")
	var levels: Dictionary
	
	for file in files:
		var level: LevelData = load(path + file)
		if not level:
			continue
		
		if not levels.has(level.id):
			levels[level.id] = level
	
	return levels

static func get_files(path: String) -> PoolStringArray:
	var files: PoolStringArray = []
	var dir: Directory = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)

	var file: String = dir.get_next()
	while file != '':
		files.append(file)
		file = dir.get_next()

	return files
