<<<<<<< HEAD
extends Spatial
class_name DeliveryTool

export var theter_anchor_path: NodePath
onready var theter_anchor: TheterAnchor = get_node(theter_anchor_path)

var objective_type = Globals.ObjectiveType.MAGNET
var carried: bool = false
var group: String
=======
extends RigidBody
class_name DeliveryTool

var objective_type = Globals.ObjectiveType.MAGNET
>>>>>>> 6d9f676 (Started delivery tools)

signal catched
