extends Node

export var surface_ambient: Color = Color("#7edaf3")
export var deep_ambient: Color = Color("#000a4e")
export var current_ambient: Color = Color.black
export var deep_factor: float = 0.0
export var enable_godray: bool = true
export var fancy_water: bool = true
export var ping360_enabled: bool = false
export var wait_SITL: bool = false
export var isHTML5: bool = false
export var physics_rate: int = 60
export var wind_dir: float = 0.0
export var wind_speed: float = 5.0
var active_vehicle = null
var active_level: String = ""
var sitl_pid: int = 0


func _ready() -> void:
	isHTML5 = OS.get_name() == "HTML5"
