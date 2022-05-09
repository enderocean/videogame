extends "res://scripts/delivery/delivery_tool.gd"
class_name MagnetDeliveryTool

export var area: NodePath

var detected_object: DeliveryObject

func _ready() -> void:
	objective_type = Globals.ObjectiveType.MAGNET
	group = "objective_%s" % str(objective_type).to_lower()


func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return

	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return

	# Make sure the object is not already in the area
	if object.get_instance_id() == detected_object.get_instance_id():
		return
	
	detected_object = object
	
	# Make the object delivered
	detected_object.delivered = true
