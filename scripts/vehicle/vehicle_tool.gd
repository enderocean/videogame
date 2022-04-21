extends Spatial
class_name VehicleTool

export var right_joint_path: NodePath
export var left_joint_path: NodePath

export var right_area_path: NodePath
export var left_area_path: NodePath

var right_joint: Joint
var left_joint: Joint

var right_area: Area
var left_area: Area

var right_rigidbody: RigidBody
var left_rigidbody: RigidBody

# TODO: Beware in case of another type of collision is used for a tool
var right_collision: CollisionPolygon
var left_collision: CollisionPolygon
var right_area_collision: CollisionPolygon
var left_area_collision: CollisionPolygon


func _ready() -> void:
	if right_joint:
		right_rigidbody = get_node(right_joint.get_node_b())
		right_collision = get_first_collision_from(right_rigidbody)
		right_area_collision = get_first_collision_from(right_rigidbody)

	if left_joint:
		right_rigidbody = get_node(right_joint.get_node_b())
		left_collision = get_first_collision_from(left_rigidbody)
		left_area_collision = get_first_collision_from(left_area)


# Makes easier to disable entirely the tool
func set_active(value: bool) -> void:
	if right_joint:
		right_rigidbody.visible = false
		right_collision.disabled = not value
		right_area_collision.disabled = not value
		right_rigidbody.pause_mode = Node.PAUSE_MODE_INHERIT

	if left_joint:
		left_rigidbody.visible = false
		left_collision.disabled = not value
		left_area_collision.disabled = not value
		left_rigidbody.pause_mode = Node.PAUSE_MODE_INHERIT
	set_physics_process(value)


# Helper to get the first CollisionPolygon from a given CollisionObject (in this case RigidBody or Area)
func get_first_collision_from(rigidbody: CollisionObject) -> CollisionPolygon:
	for child in rigidbody.get_children():
		if not child is CollisionPolygon:
			continue
		if child.disabled:
			continue
		return child
	return null
