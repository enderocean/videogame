extends Spatial
class_name DeliveryTool

export var theter_anchor_path: NodePath
onready var theter_anchor: TheterAnchor = get_node(theter_anchor_path)

export var tool_body_path: NodePath
onready var tool_body: RigidBody = get_node(tool_body_path)

var objective_type = Globals.ObjectiveType.MAGNET
var carried: bool = false
var group: String

var surface_altitude: float

signal catched
signal delivered


func _ready() -> void:
	add_to_group("objectives_nodes")


func check_delivered(object: Spatial) -> void:
	if object.global_transform.origin.y > surface_altitude:
		emit_signal("delivered", objective_type)
		object.queue_free()
		queue_free()
