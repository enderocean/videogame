extends InterpolatedCamera
class_name FollowCamera

export var target_path: NodePath setget set_target_path
var t: Spatial


func _process(_delta: float) -> void:
	if not t:
		return
	
	look_at(t.transform.origin, Vector3.UP)


func set_target_path(value: NodePath) -> void:
	target_path = value
	
	if target_path:
		t = get_node_or_null(target_path)
	
	if t:
		set_process(true)
	else:
		set_process(false)
