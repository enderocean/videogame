extends PathFollow
class_name PathFollower

export var enabled: bool = true
export var speed: float = 1.0
export var use_unit_offset: bool = true

signal started
signal stopped


func _ready() -> void:
	emit_signal("started")


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	if use_unit_offset:
		unit_offset += delta * speed
	else:
		offset += delta * speed
	
	if not loop:
		if unit_offset >= 1.0:
			emit_signal("stopped")
			enabled = false
