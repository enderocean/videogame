extends RigidBody
class_name DeliveryObject

var carried: bool = false setget set_carried
var delivered: bool = false setget set_delivered

onready var saved_gravity: float = gravity_scale
onready var saved_mask: int = collision_mask


func set_carried(value: bool) -> void:
	carried = value
	
	if carried:
		# Remove any movements
		saved_gravity = gravity_scale
		gravity_scale = 0.0
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		# Disable collision mask
		saved_mask = collision_mask
		collision_mask = 0
	else:
		if mode != RigidBody.MODE_RIGID:
			mode = RigidBody.MODE_STATIC
		
		# Reset to saved values
		gravity_scale = saved_gravity
		collision_mask = saved_mask
		
		# Refresh delivered state, if the object is dropped in the area
		delivered = delivered

func set_delivered(value: bool) -> void:
	delivered = value
	
	if delivered and not carried:
		mode = RigidBody.MODE_STATIC
#		gravity_scale = 0.0
	else:
		mode = RigidBody.MODE_RIGID
#		gravity_scale = saved_gravity
