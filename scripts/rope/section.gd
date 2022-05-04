extends RigidBody

# Should be multiplied by cross surface area of the tether, but let's keep the
# math low for now
const DRAG: float = 0.3
const LENGTH: float = 0.145


func _physics_process(_delta: float) -> void:
	var body_frame_speeds: Vector3 = self.transform.basis.xform_inv(self.linear_velocity)
	var z_speed: float = body_frame_speeds.dot(Vector3(0, 0, 1))
	var perpendicular_speed: Vector3 = body_frame_speeds - Vector3(0, 0, z_speed)
	add_central_force(self.transform.basis.xform(-perpendicular_speed * DRAG))
