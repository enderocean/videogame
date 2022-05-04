extends PathFollow

export var speed: float = 1.0


func _physics_process(delta: float) -> void:
	
	unit_offset += delta * speed
