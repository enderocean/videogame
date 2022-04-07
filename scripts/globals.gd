extends Node

const SEND_DATA: bool = false

export var isHTML5: bool = false

export var surface_ambient: Color = Color("#7edaf3")
export var deep_ambient: Color = Color("#000a4e")
export var current_ambient: Color = Color.black
export var deep_factor: float = 0.0

export var enable_godray: bool = true setget set_enable_godray
export var fancy_water: bool = true setget set_fancy_water
export var ping360_enabled: bool = false
export var wait_SITL: bool = false

export var physics_rate: int = 60 setget set_physics_rate
export var wind_dir: float = 0.0
export var wind_speed: float = 5.0

var user_data: Dictionary = {
	"name": "",
	"score": 0
}

var levels: Array

var active_vehicle = null
var sitl_pid: int = 0

signal fancy_water_changed
signal enable_godray_changed
signal physics_rate_changed


func _ready() -> void:
	# Ensure this node is not being paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	isHTML5 = OS.get_name() == "HTML5"
	
	# Load levels data
	levels = LevelData.get_levels()

func set_fancy_water(value: bool) -> void:
	fancy_water = value
	emit_signal("fancy_water_changed")


func set_enable_godray(value: bool) -> void:
	enable_godray = value
	emit_signal("enable_godray_changed")


func set_physics_rate(value: int) -> void:
	physics_rate = value
	Engine.iterations_per_second = value
