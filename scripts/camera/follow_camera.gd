extends Camera
class_name FollowCamera

export var speed: float = 1
export var distance: float = 1

export var target_path: NodePath
onready var target: Spatial = get_node_or_null(target_path)


func _physics_process(delta: float) -> void:
	if not target:
		return

	var current_distance: float = global_transform.origin.distance_to(
		target.global_transform.origin
	)
	var direction: Vector3 = global_transform.origin.direction_to(target.global_transform.origin)

	look_at(target.global_transform.origin, Vector3.UP)

	if current_distance > distance:
		global_transform.origin = global_transform.origin.linear_interpolate(
			target.global_transform.origin + direction * distance, delta
		)
