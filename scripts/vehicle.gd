extends Spatial
class_name Vehicle

export var camera_target_path: NodePath
onready var camera_target: Spatial = get_node_or_null(camera_target_path)

export var theter_anchor_path: NodePath
onready var theter_anchor: PhysicsBody = get_node_or_null(theter_anchor_path)
