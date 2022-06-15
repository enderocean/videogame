tool
extends PathFollow

export var enabled: bool = true setget set_enabled
export var speed: float = 1.0
var time: float = 0.0


func set_enabled(value: bool) -> void:
	enabled = value
	reset()


func reset() -> void:
	time = 0.0
	offset = 0.0
	transform.origin = Vector3.ZERO
	rotation_degrees = Vector3.ZERO


func _ready() -> void:
	reset()


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	if time > 60.0:
		time = 0
	
	time += delta
	offset += (cos(time) * 4.0 + 6.0) * speed / 1000

