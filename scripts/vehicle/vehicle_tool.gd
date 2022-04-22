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

var collisions: Dictionary = {
	"right_rigidbody": {
		"layer": 0,
		"mask": 0,
	},
	"left_rigidbody": {
		"layer": 0,
		"mask": 0,
	},
	"right_area": {
		"layer": 0,
		"mask": 0,
	},
	"left_area": {
		"layer": 0,
		"mask": 0,
	},
}

func _ready() -> void:
	if right_rigidbody:
#		right_collision = get_first_collision_from(right_rigidbody)
		collisions["right_rigidbody"]["layer"] = right_rigidbody.collision_layer
		collisions["right_rigidbody"]["mask"] = right_rigidbody.collision_mask

	if left_rigidbody:
#		left_collision = get_first_collision_from(left_rigidbody)
		collisions["left_rigidbody"]["layer"] = left_rigidbody.collision_layer
		collisions["left_rigidbody"]["mask"] = left_rigidbody.collision_mask

	if right_area:
#		right_area_collision = get_first_collision_from(right_area)
		collisions["right_area"]["layer"] = right_area.collision_layer
		collisions["right_area"]["mask"] = right_area.collision_mask

	if left_area:
#		left_area_collision = get_first_collision_from(left_area)
		collisions["left_area"]["layer"] = left_area.collision_layer
		collisions["left_area"]["mask"] = left_area.collision_mask


# Makes easier to disable entirely the tool
func set_active(value: bool) -> void:
	if right_rigidbody:
		right_rigidbody.visible = value
		
		if value:
			right_rigidbody.collision_layer = collisions["right_rigidbody"]["layer"]
			right_rigidbody.collision_mask = collisions["right_rigidbody"]["mask"]
		else:
			right_rigidbody.collision_layer = 0
			right_rigidbody.collision_mask = 0
	
	if left_rigidbody:
		left_rigidbody.visible = value
		
		if value:
			left_rigidbody.collision_layer = collisions["left_rigidbody"]["layer"]
			left_rigidbody.collision_mask = collisions["left_rigidbody"]["mask"]
		else:
			left_rigidbody.collision_layer = 0
			left_rigidbody.collision_mask = 0
	
	if left_area:
		if value:
			right_rigidbody.collision_layer = collisions["left_area"]["layer"]
			right_rigidbody.collision_mask = collisions["left_area"]["mask"]
		else:
			right_rigidbody.collision_layer = 0
			right_rigidbody.collision_mask = 0
	
	if right_area:
		if value:
			right_rigidbody.collision_layer = collisions["right_area"]["layer"]
			right_rigidbody.collision_mask = collisions["right_area"]["mask"]
		else:
			right_rigidbody.collision_layer = 0
			right_rigidbody.collision_mask = 0

	set_physics_process(value)


func move_left(value: float) -> void:
	if not left_joint:
		return
	
	left_joint.set_param(left_joint.PARAM_MOTOR_TARGET_VELOCITY, value)


func move_right(value: float) -> void:
	if not right_joint:
		return
	
	right_joint.set_param(right_joint.PARAM_MOTOR_TARGET_VELOCITY, value)
