extends Spatial
class_name DeliveryTool

export var theter_anchor_path: NodePath
onready var theter_anchor: TheterAnchor = get_node(theter_anchor_path)

var objective_type = Globals.ObjectiveType.MAGNET
var group: String

signal catched
