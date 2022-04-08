extends InterpolatedCamera
class_name FollowCamera

export var target_path: NodePath
var target_node: Spatial

func _ready() -> void:
	if target_path:
#		target = target_path
		target_node = get_node(target_path)

func _physics_process(delta: float) -> void:
	if not target_node:
		return
	
	look_at(target_node.global_transform.origin, Vector3.UP)
