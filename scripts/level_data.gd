extends Resource
class_name LevelData

export(String, FILE, "*.tscn") var scene: String

export var title: String = ""
export(String, MULTILINE) var description: String = ""

export var tools: PoolStringArray
export var objectives: PoolStringArray


static func get_levels() -> Array:
	var path: String = "res://assets/levels/"
	var files: PoolStringArray = get_files("res://assets/levels/")
	var levels: Array
	
	for file in files:
		var level: LevelData = load(path + file)
		if not level:
			continue
		
		levels.append(level)
	
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
