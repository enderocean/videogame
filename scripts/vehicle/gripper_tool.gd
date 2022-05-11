extends "res://scripts/vehicle/vehicle_tool.gd"
class_name GripperTool

export var carry_position_path: NodePath
onready var carry_position: Position3D = get_node(carry_position_path)

var grips: Array = [false, false]
var carrying_object: DeliveryObject


func _ready() -> void:
	._ready()
	tool_type = Globals.ObjectiveType.GRIPPER
	
	if left_area:
		left_area.connect("body_entered", self, "_on_left_area_body_entered")
		left_area.connect("body_exited", self, "_on_left_area_body_exited")
	
	if right_area:
		right_area.connect("body_entered", self, "_on_right_area_body_entered")
		right_area.connect("body_exited", self, "_on_right_area_body_exited")


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
	# Carry object
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


func _on_left_area_body_entered(body: Node) -> void:
	if carrying_object or is_valid_body(body):
		return

	grips[0] = true
	check_carry(body)


func _on_left_area_body_exited(body: Node) -> void:
	if carrying_object or is_valid_body(body):
		return

	grips[0] = false


func _on_right_area_body_entered(body: Node) -> void:
	if carrying_object or is_valid_body(body):
		return

	grips[1] = true
	check_carry(body)


func _on_right_area_body_exited(body: Node) -> void:
	if carrying_object or is_valid_body(body):
		return

	grips[1] = false


func is_valid_body(body: Node) -> bool:
	if body is DeliveryObject:
		return true
	if body.get_parent() is DeliveryTool:
		return true
	return false
