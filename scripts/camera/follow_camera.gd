extends Camera
class_name FollowCamera

#export var speed: float = 2
export var distance: float = 5

export var target_path: NodePath
onready var target: Spatial = get_node_or_null(target_path)


func _physics_process(delta: float) -> void:
	if not target:
		return

	var direction: Vector3 = global_transform.origin - target.global_transform.origin
	var length: float = (global_transform.origin - target.global_transform.origin).length()
	if length > distance:
		global_transform.origin = target.global_transform.origin + direction * distance / length
	
	look_at(target.global_transform.origin, Vector3.UP)
