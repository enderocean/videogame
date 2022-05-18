extends Resource
class_name CollectibleData

export var id: String = "collectible_id"

export var title: String = ""
export(String, MULTILINE) var description: String = ""
export(String, FILE, "*.jpg, *.png") var image: String


static func get_collectibles() -> Dictionary:
	var path: String = "res://assets/collectibles/"
	var files: PoolStringArray = Globals.get_files(path)
	var data: Dictionary = {}
	var file: File = File.new()

	for file_name in files:
		if not file.file_exists(path + file_name):
			continue

		var collectible: CollectibleData = load(path + file_name)
		if not collectible:
			continue

		if not data.has(collectible.id):
			data[collectible.id] = collectible

	return data
