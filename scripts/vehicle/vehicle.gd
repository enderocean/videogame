extends Spatial
class_name Vehicle

export var vehicle_body_path: NodePath
onready var vehicle_body: PhysicsBody = get_node_or_null(vehicle_body_path)

export var camera_target_path: NodePath
onready var camera_target: Spatial = get_node_or_null(camera_target_path)

export var theter_anchor_path: NodePath
onready var theter_anchor: Spatial = get_node_or_null(theter_anchor_path)
