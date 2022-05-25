extends MeshInstance
class_name UnderwaterMesh

var target: NodePath setget _set_target
var _target: Spatial


func _set_target(value: NodePath) -> void:
	_target = get_node_or_null(value)


func _physics_process(delta: float) -> void:
	if not _target:
		return
	
	global_transform.origin = _target.global_transform.origin
