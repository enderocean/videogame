extends "res://scripts/vehicle/vehicle_tool.gd"
class_name GripperTool

export var carry_position_path: NodePath
onready var carry_position: Position3D = get_node(carry_position_path)

var grips: Array = [false, false]
var carrying_object: DeliveryObject


func _physics_process(_delta: float) -> void:
	if not carrying_object:
		return

	carrying_object.global_transform.origin = carry_position.global_transform.origin
	carrying_object.global_transform.basis = carry_position.global_transform.basis


func can_carry() -> bool:
	# Check for the size of the collider
	for i in range(grips.size()):
		if not grips[i]:
			return false
	return true


func check_carry(body: DeliveryObject) -> void:
	var carrying: bool = can_carry()
	if carrying:
		carry_object(body)
	else:
		release_object()


func carry_object(body: DeliveryObject) -> void:
	body.carried = true

	# Save position and rotation of the object before "freezing" it
	carry_position.global_transform.origin = body.global_transform.origin
	carry_position.global_transform.basis = body.global_transform.basis

	carrying_object = body


func release_object() -> void:
	if not carrying_object:
		return

	carrying_object.carried = false
	carrying_object = null


func _on_LeftGripArea_body_entered(body: Node) -> void:
	if carrying_object or not body is DeliveryObject:
		return

	grips[0] = true
	check_carry(body)


func _on_LeftGripArea_body_exited(body: Node) -> void:
	if carrying_object or not body is DeliveryObject:
		return

	grips[0] = false


func _on_RightGripArea_body_entered(body: Node) -> void:
	if carrying_object or not body is DeliveryObject:
		return

	grips[1] = true
	check_carry(body)


func _on_RightGripArea_body_exited(body: Node) -> void:
	if carrying_object or not body is DeliveryObject:
		return

	grips[1] = false
