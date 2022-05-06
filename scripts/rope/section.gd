extends RigidBody

onready var collision: Dictionary = {"layer": collision_layer, "mask": collision_mask}

var previous_joint: Joint
var joint: Joint

# Should be multiplied by cross surface area of the tether, but let's keep the
# math low for now
const DRAG: float = 0.3
const LENGTH: float = 0.145


func _physics_process(_delta: float) -> void:
	var body_frame_speeds: Vector3 = self.transform.basis.xform_inv(self.linear_velocity)
	var z_speed: float = body_frame_speeds.dot(Vector3(0, 0, 1))
	var perpendicular_speed: Vector3 = body_frame_speeds - Vector3(0, 0, z_speed)
	add_central_force(self.transform.basis.xform(-perpendicular_speed * DRAG))


func _on_visibility_changed() -> void:
	if visible:
		collision_layer = collision.get("layer")
		collision_mask = collision.get("mask")
	else:
		collision_layer = 0
		collision_mask = 0
