extends Spatial
class_name Vehicle

export var camera_target_path: NodePath
onready var camera_target: Spatial = get_node_or_null(camera_target_path)
