extends RigidBody
class_name DeliveryObject

export(Globals.ObjectiveType) var objective_type = Globals.ObjectiveType.GRIPPER
export(float, 0.0, 2.0) var object_gravity_scale: float = 0.1

var carried: bool = false setget set_carried
var delivered: bool = false setget set_delivered

onready var saved_gravity: float = gravity_scale
onready var saved_mask: int = collision_mask

signal delivered


func _ready() -> void:
	gravity_scale = 0.1
	add_to_group("objective_%s" % str(objective_type))
#	print("Added to group: ", "objective_%s" % str(objective_type))
	# Set the "catchable" collision layer automatically
	set_collision_layer_bit(1, true)



func set_carried(value: bool) -> void:
	carried = value

	if carried:
		# Remove any movements
		saved_gravity = gravity_scale
		gravity_scale = 0.0
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		# Disable collision mask
#		saved_mask = collision_mask
#		collision_mask = 0
	else:
		# Reset to saved values
		gravity_scale = saved_gravity
#		collision_mask = saved_mask

		# Refresh delivered state, if the object is dropped in the area
		delivered = delivered


func set_delivered(value: bool) -> void:
	if carried:
		return

	delivered = value
	if delivered:
		emit_signal("delivered")
