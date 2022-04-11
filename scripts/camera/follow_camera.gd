extends Camera
class_name FollowCamera

export var speed: float = 1
export var distance: float = 1

export var target_path: NodePath
onready var target: Spatial = get_node_or_null(target_path)


func _physics_process(delta: float) -> void:
	if not target:
		return
	
	var direction: Vector3 = global_transform.origin.direction_to(target.global_transform.origin)
	global_transform = global_transform.interpolate_with(target.global_transform, speed * delta) # .origin.linear_interpolate(target.global_transform.origin + direction * distance, delta)
	look_at(target.global_transform.origin, Vector3.UP)
