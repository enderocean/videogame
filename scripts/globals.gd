extends Node

enum ObjectiveType {
	GRIPPER,
	VACUUM,
	CUTTER,
	GRAPPLING_HOOK,
	MAGNET,
	ANIMAL,
}

enum DeliveryToolType {
	GRAPPLING_HOOK,
	MAGNET,
}

const SEND_DATA: bool = false

const LINKS: Dictionary = {
	"session": "https://www.enderocean.com/en/training-center/",
	"events": "https://www.enderocean.com/events/"
}

export var isHTML5: bool = false

export var enable_godray: bool = true setget set_enable_godray
export var fancy_water: bool = true setget set_fancy_water
export var ping360_enabled: bool = false setget set_ping360
export var wait_SITL: bool = false

export var physics_rate: int = 60 setget set_physics_rate
export var wind_dir: float = 0.0
export var wind_speed: float = 5.0

var levels: Dictionary
var collectibles: Dictionary

var sitl_pid: int = 0


signal fancy_water_changed
signal enable_godray_changed
signal physics_rate_changed
signal ping360_changed


func _ready() -> void:
	# Ensure this node is not being paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	isHTML5 = OS.get_name() == "HTML5"

	# Load levels data
	levels = LevelData.get_levels()
	collectibles = CollectibleData.get_collectibles()


func set_fancy_water(value: bool) -> void:
	fancy_water = value
	emit_signal("fancy_water_changed")


func set_enable_godray(value: bool) -> void:
	enable_godray = value
	emit_signal("enable_godray_changed")


func set_physics_rate(value: int) -> void:
	physics_rate = value
	Engine.iterations_per_second = value


func set_ping360(value: bool) -> void:
	ping360_enabled = value
	emit_signal("ping360_changed")


static func get_files(path: String) -> PoolStringArray:
	var files: PoolStringArray = []
	var dir: Directory = Directory.new()

	var error: int = dir.open(path)
	if error != OK:
		return files

	error = dir.list_dir_begin(true)
	if error != OK:
		return files

	var file: String = dir.get_next()
	while file != "":
		files.append(file)
		file = dir.get_next()

	return files


# TODO: Save settings to file
