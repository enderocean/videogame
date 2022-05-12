extends Spatial
class_name DeliveryTool

export var theter_anchor_path: NodePath
onready var theter_anchor: TheterAnchor = get_node(theter_anchor_path)

export var tool_body_path: NodePath
onready var tool_body: RigidBody = get_node(tool_body_path)

var objective_type = Globals.ObjectiveType.MAGNET
var carried: bool = false
var group: String

signal catched
