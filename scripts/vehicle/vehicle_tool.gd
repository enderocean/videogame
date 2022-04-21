extends Spatial
class_name VehicleTool

export var right_joint_path: NodePath
export var left_joint_path: NodePath

export var right_rigidbody_path: NodePath
export var left_rigidbody_path: NodePath

export var right_area_path: NodePath
export var left_area_path: NodePath

onready var right_joint: Joint = get_node_or_null(right_joint_path)
onready var right_rigidbody: RigidBody = get_node_or_null(right_rigidbody_path)
onready var right_area: Area = get_node_or_null(right_area_path)

onready var left_joint: Joint = get_node_or_null(left_joint_path)
onready var left_rigidbody: RigidBody = get_node_or_null(left_rigidbody_path)
onready var left_area: Area = get_node_or_null(left_area_path)

# TODO: Beware in case of another type of collision is used for a tool
var right_collision: CollisionPolygon
var right_area_collision: CollisionPolygon
var left_collision: CollisionPolygon
var left_area_collision: CollisionPolygon


func _ready() -> void:
	if right_rigidbody:
		right_collision = get_first_collision_from(right_rigidbody)

	if right_area:
		right_area_collision = get_first_collision_from(right_area)

	if left_rigidbody:
		left_collision = get_first_collision_from(left_rigidbody)

	if left_area:
		left_area_collision = get_first_collision_from(left_area)


# Makes easier to disable entirely the tool
func set_active(value: bool) -> void:
	if right_rigidbody:
		right_rigidbody.visible = value
		right_rigidbody.pause_mode = Node.PAUSE_MODE_INHERIT

	if right_collision:
		right_collision.disabled = not value

	if right_area_collision:
		right_area_collision.disabled = not value

	if left_rigidbody:
		left_rigidbody.visible = value
		left_rigidbody.pause_mode = Node.PAUSE_MODE_INHERIT

	if left_collision:
		left_collision.disabled = not value

	if left_area_collision:
		left_area_collision.disabled = not value

	set_physics_process(value)


# Helper to get the first CollisionPolygon from a given CollisionObject (in this case RigidBody or Area)
func get_first_collision_from(collision: CollisionObject) -> CollisionPolygon:
	for child in collision.get_children():
		if not child is CollisionPolygon:
			continue
		return child
	return null


func move_left(value: float) -> void:
	if not left_joint:
		return
	
	left_joint.set_param(left_joint.PARAM_MOTOR_TARGET_VELOCITY, value)


func move_right(value: float) -> void:
	if not right_joint:
		return
	
	right_joint.set_param(right_joint.PARAM_MOTOR_TARGET_VELOCITY, value)
