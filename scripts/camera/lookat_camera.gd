extends Camera
class_name LookAtCamera

export var target_path: NodePath
var target: Spatial


func _ready() -> void:
	if target_path:
		target = get_node(target_path)


func _physics_process(delta: float) -> void:
	if not target:
		return
	
	look_at(target.global_transform.origin, Vector3.UP)
