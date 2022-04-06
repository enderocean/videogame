extends Camera
class_name LookAtCamera

export var target_path: NodePath setget set_target_path
var target: Spatial

func _ready() -> void:
	set_target_path(target_path)


func _process(_delta: float) -> void:
	if not target:
		return
	
	look_at(target.transform.origin, Vector3.UP)


func set_target_path(value: NodePath) -> void:
	target_path = value
	
	if target_path:
		target = get_node_or_null(target_path)
	
	if target:
		set_process(true)
	else:
		set_process(false)
