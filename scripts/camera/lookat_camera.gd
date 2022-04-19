extends Camera
class_name LookAtCamera

export var target_path: NodePath
onready var target: Spatial = get_node_or_null(target_path)


func _physics_process(delta: float) -> void:
	if not target:
		return

	look_at(target.global_transform.origin, Vector3.UP)
