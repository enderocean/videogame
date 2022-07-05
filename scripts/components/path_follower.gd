extends PathFollow
class_name PathFollower

export var enabled: bool = true
export var speed: float = 1.0
export var use_unit_offset: bool = true

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	if use_unit_offset:
		unit_offset += delta * speed
	else:
		offset += delta * speed
