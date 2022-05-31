extends "res://scripts/vehicle/vehicle_tool.gd"
class_name GripperTool

export var carry_position_path: NodePath
onready var carry_position: Position3D = get_node(carry_position_path)

var grips: Array = [false, false]
var carrying_object: Spatial


func _ready() -> void:
	._ready()
	tool_type = Globals.ObjectiveType.GRIPPER
	
	if left_area:
	# warning-ignore:return_value_discarded
		left_area.connect("body_entered", self, "_on_left_area_body_entered")
	# warning-ignore:return_value_discarded
		left_area.connect("body_exited", self, "_on_left_area_body_exited")
	
	if right_area:
	# warning-ignore:return_value_discarded
		right_area.connect("body_entered", self, "_on_right_area_body_entered")
	# warning-ignore:return_value_discarded
		right_area.connect("body_exited", self, "_on_right_area_body_exited")


func _physics_process(_delta: float) -> void:
	if not carrying_object:
		return

	carrying_object.global_transform.origin = carry_position.global_transform.origin
	carrying_object.global_transform.basis = carry_position.global_transform.basis


func check_grips_colliding() -> bool:
	# Check for the size of the collider
	for i in range(grips.size()):
		if not grips[i]:
			return false
	# Carry object
	return true


func check_carry(body) -> void:
	var delivery_tool: DeliveryTool = get_delivery_tool(body)
	if delivery_tool and delivery_tool.sticked:
		return
	
	var carrying: bool = check_grips_colliding()
	if carrying:
		carry_object(body)
	else:
		release_object()


func carry_object(body) -> void:
	if body is DeliveryObject:
		body.carried = true
	var delivery_tool: DeliveryTool = get_delivery_tool(body)
	if delivery_tool:
		delivery_tool.carried = true
	
	# Save position and rotation of the object before "freezing" it
	carry_position.global_transform.origin = body.global_transform.origin
	carry_position.global_transform.basis = body.global_transform.basis

	carrying_object = body


func release_object() -> void:
	if not carrying_object:
		return
	
	if carrying_object is DeliveryObject:
		carrying_object.linear_velocity = Vector3.ZERO
		carrying_object.angular_velocity = Vector3.ZERO
		carrying_object.carried = false
	
	var delivery_tool: DeliveryTool = get_delivery_tool(carrying_object)
	if delivery_tool:
		delivery_tool.tool_body.linear_velocity = Vector3.ZERO
		delivery_tool.tool_body.angular_velocity = Vector3.ZERO
		delivery_tool.carried = false
	
	carrying_object = null


func _on_left_area_body_entered(body: Node) -> void:
	if carrying_object or not is_valid_body(body):
		return
	
	grips[0] = true
	check_carry(body)


func _on_left_area_body_exited(body: Node) -> void:
	if carrying_object or not is_valid_body(body):
		return

	grips[0] = false


func _on_right_area_body_entered(body: Node) -> void:
	if carrying_object or not is_valid_body(body):
		return

	grips[1] = true
	check_carry(body)


func _on_right_area_body_exited(body: Node) -> void:
	if carrying_object or not is_valid_body(body):
		return

	grips[1] = false


func is_valid_body(body: Node) -> bool:
	if not body:
		return false
	
	if body is DeliveryObject:
		if not body.is_in_group("objective_%s" % str(tool_type).to_lower()):
			return false
		return true
	
	var delivery_tool: DeliveryTool = get_delivery_tool(body)
	if delivery_tool:
		return true
	
	return false


func get_delivery_tool(body: Node) -> DeliveryTool:
	var parent = body.get_parent()
	if parent is DeliveryTool:
		return parent
	if parent.get_parent() is DeliveryTool:
		return parent.get_parent()
	return null
