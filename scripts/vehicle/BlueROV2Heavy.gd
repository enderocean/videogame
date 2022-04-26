tool
extends RigidBody

const THRUST = 50

var interface = PacketPeerUDP.new()  # UDP socket for fdm in (server)
var peer = null
var start_time = OS.get_ticks_msec()

var last_velocity = Vector3(0, 0, 0)
var calculated_acceleration = Vector3(0, 0, 0)

var buoyancy = 1.6 + self.mass * 9.8  # Newtons
var _initial_position = Vector3.ZERO
var phys_time = 0

export var speeds: PoolVector2Array = [
	Vector2(20, 50),
	Vector2(40, 70),
	Vector2(80, 100),
]
var speed_index: int = 0

onready var camera: Camera = get_node("Camera")

onready var lights: Array = [
	get_node("light1"),
	get_node("light2"),
	get_node("light3"),
	get_node("light4"),
]

onready var scatterlight: Light = get_node("scatterlight")

onready var light_glows: Array = [
	get_node("light_glow"),
	get_node("light_glow2"),
	get_node("light_glow3"),
	get_node("light_glow4"),
]

var thrusters: Array = []

export var sounds_path: NodePath
onready var sounds: ROVSounds = get_node(sounds_path)

export var gripper_path: NodePath
onready var gripper: GripperTool = get_node(gripper_path)

export var cutter_path: NodePath
onready var cutter: CutterTool = get_node(cutter_path)

export var vacuum_path: NodePath
onready var vacuum: VacuumTool = get_node(vacuum_path)

var vehicle_tools: Array
var vehicle_tool_index: int

onready var wait_SITL = Globals.wait_SITL


func connect_fmd_in() -> void:
	if interface.listen(9002) != OK:
		print("Failed to connect fdm_in")


func get_servos() -> void:
	if not peer:
		interface.set_dest_address("127.0.0.1", interface.get_packet_port())

	if not interface.get_available_packet_count():
		if wait_SITL:
			interface.wait()
		else:
			return

	var buffer = StreamPeerBuffer.new()
	buffer.data_array = interface.get_packet()

	var magic = buffer.get_u16()
	buffer.seek(2)
	var _framerate = buffer.get_u16()
	#print(_framerate)
	buffer.seek(4)
	var _framecount = buffer.get_u16()

	if magic != 18458:
		return
	for i in range(0, 15):
		buffer.seek(8 + i * 2)
		actuate_servo(i, (float(buffer.get_u16()) - 1000) / 1000)


func send_fdm() -> void:
	var buffer = StreamPeerBuffer.new()

	buffer.put_double((OS.get_ticks_msec() - start_time) / 1000.0)

	var _basis = transform.basis

# These are the same but mean different things, let's keep both for now
	var toNED = Basis(Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(1, 0, 0))

	toNED = Basis(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0))

	var toFRD = Basis(Vector3(0, -1, 0), Vector3(0, 0, -1), Vector3(1, 0, 0))

	var _angular_velocity = toFRD.xform(_basis.xform_inv(angular_velocity))
	var gyro = [_angular_velocity.x, _angular_velocity.y, _angular_velocity.z]

	var _acceleration = toFRD.xform(_basis.xform_inv(calculated_acceleration))

	var accel = [_acceleration.x, _acceleration.y, _acceleration.z]

	# var orientation = toFRD.xform(Vector3(-rotation.x, - rotation.y, -rotation.z))
	var quaternon = Basis(-_basis.z, _basis.x, _basis.y).rotated(Vector3(1, 0, 0), PI).rotated(Vector3(1, 0, 0), PI / 2).get_rotation_quat()

	var euler = quaternon.get_euler()
	euler = [euler.y, euler.x, euler.z]

	var _velocity = toNED.xform(self.linear_velocity)
	var velo = [_velocity.x, _velocity.y, _velocity.z]

	var _position = toNED.xform(self.transform.origin)
	var pos = [_position.x, _position.y, _position.z]

	var IMU_fmt = {"gyro": gyro, "accel_body": accel}
	var JSON_fmt = {
		"timestamp": phys_time,
		"imu": IMU_fmt,
		"position": pos,
		"quaternion": [quaternon.w, quaternon.x, quaternon.y, quaternon.z],
		"velocity": velo
	}
	var JSON_string = "\n" + JSON.print(JSON_fmt) + "\n"
	buffer.put_utf8_string(JSON_string)
	interface.put_packet(buffer.data_array)


func get_motors_table_entry(thruster) -> Array:
	var thruster_vector = (thruster.transform.basis * Vector3(1, 0, 0)).normalized()
	var roll = Vector3(0, 0, -1).cross(thruster.translation).normalized().dot(thruster_vector)
	var pitch = Vector3(1, 0, 0).cross(thruster.translation).normalized().dot(thruster_vector)
	var yaw = Vector3(0, 1, 0).cross(thruster.translation).normalized().dot(thruster_vector)
	var forward = Vector3(0, 0, -1).dot(thruster_vector)
	var lateral = Vector3(1, 0, 0).dot(thruster_vector)
	var vertical = Vector3(0, -1, 0).dot(thruster_vector)
	if abs(roll) < 0.15 or not thruster.roll_factor:
		roll = 0
	if abs(pitch) < 0.15 or not thruster.pitch_factor:
		pitch = 0
	if abs(yaw) < 0.15 or not thruster.yaw_factor:
		yaw = 0
	if abs(vertical) < 0.15 or not thruster.vertical_factor:
		vertical = 0
	if abs(forward) < 0.15 or not thruster.forward_factor:
		forward = 0
	if abs(lateral) < 0.15 or not thruster.lateral_factor:
		lateral = 0
	return [roll, pitch, yaw, vertical, forward, lateral]


func calculate_motors_matrix() -> void:
	print("Calculated Motors Matrix:")
	var i = 1
	for thruster in thrusters:
		var entry = get_motors_table_entry(thruster)
		entry.insert(0, i)
		i = i + 1
		print("add_motor_raw_6dof(AP_MOTORS_MOT_%s,\t%s,\t%s,\t%s,\t%s,\t%s,\t%s);" % entry)


func _ready() -> void:
	if Engine.is_editor_hint():
		calculate_motors_matrix()
		return

	# Fill tools array
	for child in get_parent().get_children():
		if not child is VehicleTool:
			continue	
		if not child.enabled:
			continue
	
		vehicle_tools.append(child)

	# Fill thrusters array
	for child in get_children():
		if child.get_class() == "Thruster":
			thrusters.append(child)

	_initial_position = global_transform.origin
	set_physics_process(true)
	
	if not Globals.isHTML5:
		connect_fmd_in()
	
	# We need to wait before setting the default tool, idk why
	yield(get_tree().create_timer(0.01), "timeout")
	set_current_tool(vehicle_tool_index)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	phys_time = phys_time + 1.0 / Globals.physics_rate
	process_keys()

	if Globals.isHTML5:
		return

	calculated_acceleration = (linear_velocity - last_velocity) / delta
	calculated_acceleration.y += 10
	last_velocity = linear_velocity

	get_servos()
	send_fdm()


func add_force_local(force: Vector3, pos: Vector3) -> void:
	var pos_local: Vector3 = transform.basis.xform(pos)
	var force_local: Vector3 = transform.basis.xform(force)
	add_force(force_local, pos_local)


func actuate_servo(id: int, percentage: float) -> void:
	if percentage == 0:
		return

	var force = (percentage - 0.5) * 2 * -THRUST

	# Thrusters
	if id >= 0 and id <= 7:
		add_force_local(
			thrusters[id].transform.basis * Vector3(force, 0, 0), thrusters[id].translation
		)

	match id:
		8:
			camera.rotation_degrees.x = -45 + 90 * percentage
		9:
			percentage -= 0.1

			for i in range(lights.size()):
				lights[i].light_energy = percentage * 5

			scatterlight.light_energy = percentage * 2.5

			if percentage < 0.01 and light_glows[0].get_parent() != null:
				for light in light_glows:
					remove_child(light)
			elif percentage > 0.01 and light_glows[0].get_parent() == null:
				for light in light_glows:
					add_child(light)

		10:
			if percentage < 0.4:
				vehicle_tools[vehicle_tool_index].move_left(1)
				vehicle_tools[vehicle_tool_index].move_right(-1)
			elif percentage > 0.6:
				vehicle_tools[vehicle_tool_index].move_left(-1)
				vehicle_tools[vehicle_tool_index].move_right(1)
			else:
				vehicle_tools[vehicle_tool_index].move_left(0)
				vehicle_tools[vehicle_tool_index].move_right(0)


func _unhandled_input(event) -> void:
	if event is InputEventKey:
		# 	# There are for debugging:
		# 	# Some forces:
		# 	if event.pressed and event.scancode == KEY_X:
		# 		add_central_force(Vector3(30, 0, 0))
		# 	if event.pressed and event.scancode == KEY_Y:
		# 		add_central_force(Vector3(0, 30, 0))
		# 	if event.pressed and event.scancode == KEY_Z:
		# 		add_central_force(Vector3(0, 0, 30))
		# 	# Reset position
		# 	if event.pressed and event.scancode == KEY_R:
		# 		set_translation(_initial_position)
		# 	# Some torques
		# 	if event.pressed and event.scancode == KEY_Q:
		# 		add_torque(self.transform.basis.xform(Vector3(15, 0, 0)))
		# 	if event.pressed and event.scancode == KEY_T:
		# 		add_torque(self.transform.basis.xform(Vector3(0, 15, 0)))
		# 	if event.pressed and event.scancode == KEY_E:
		# 		add_torque(self.transform.basis.xform(Vector3(0, 0, 15)))

		# Some hard-coded positions (used to check accelerometer)
		# if event.pressed and event.scancode == KEY_U:
		# 	self.look_at(Vector3(0, 100, 0), Vector3(0, 0, 1))  # expects +X
		# 	mode = RigidBody.MODE_STATIC
		# if event.pressed and event.scancode == KEY_I:
		# 	self.look_at(Vector3(100, 0, 0), Vector3(0, 100, 0))  #expects +Z
		# 	mode = RigidBody.MODE_STATIC
		# if event.pressed and event.scancode == KEY_O:
		# 	self.look_at(Vector3(100, 0, 0), Vector3(0, 0, -100))  #expects +Y
		# 	mode = RigidBody.MODE_STATIC

		if event.pressed and event.is_action("camera_switch"):
			if camera.is_current():
				camera.clear_current(true)
			else:
				camera.set_current(true)

	if event.is_action("lights_up"):
		var percentage = min(max(0, lights[0].light_energy + 0.1), 5)
		if percentage > 0:
			for light in light_glows:
				add_child(light)

		for i in range(lights.size()):
			lights[i].light_energy = percentage
		scatterlight.light_energy = percentage * 0.5

	if event.is_action("lights_down"):
		var percentage: float = min(max(0, lights[0].light_energy - 0.1), 5)
		if percentage == 0:
			for light in light_glows:
				remove_child(light)

		for i in range(lights.size()):
			lights[i].light_energy = percentage
		scatterlight.light_energy = percentage * 0.5


func process_keys() -> void:
	var force: Vector3 = Vector3.ZERO
	var pos: Vector3 = Vector3(0, -0.05, 0)

	if Input.is_action_just_pressed("speed_up"):
		speed_index = clamp(speed_index + 1, 0, speeds.size())

	if Input.is_action_just_pressed("speed_down"):
		speed_index = clamp(speed_index - 1, 0, speeds.size())

	if Input.is_action_pressed("forward"):
		force.z = speeds[speed_index].x
		sounds.play("move_forward")
	else:
		sounds.stop("move_forward")

	if Input.is_action_pressed("backwards"):
		force.z = -speeds[speed_index].x
		sounds.play("move_backward")
	else:
		sounds.stop("move_backward")

	if Input.is_action_pressed("strafe_right"):
		force.x = -speeds[speed_index].x
		sounds.play("move_right")
	else:
		sounds.stop("move_right")

	if Input.is_action_pressed("strafe_left"):
		force.x = speeds[speed_index].x
		sounds.play("move_left")
	else:
		sounds.stop("move_left")

	if Input.is_action_pressed("upwards"):
		force.y = speeds[speed_index].y
		sounds.play("move_up")
		sounds.stop("move_down")
	elif Input.is_action_pressed("downwards"):
		force.y = -speeds[speed_index].y

		sounds.stop("move_up")
		sounds.play("move_down")
	else:
		sounds.stop("move_up")
		sounds.stop("move_down")

	if force != Vector3.ZERO:
		add_force_local(force, pos)

	var torque: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("rotate_left"):
		torque = transform.basis.xform(Vector3(0, 20, 0))
	elif Input.is_action_pressed("rotate_right"):
		torque = transform.basis.xform(Vector3(0, -20, 0))

	if torque != Vector3.ZERO:
		add_torque(torque)

	if Input.is_action_pressed("camera_up"):
		camera.rotation_degrees.x = min(camera.rotation_degrees.x + 0.1, 45)
		sounds.stop("camera_down")
		sounds.play("camera_up")
	elif Input.is_action_pressed("camera_down"):
		camera.rotation_degrees.x = max(camera.rotation_degrees.x - 0.1, -45)
		sounds.stop("camera_up")
		sounds.play("camera_down")
	else:
		sounds.stop("camera_up")
		sounds.stop("camera_down")

	# Switch tool
	if Input.is_action_just_pressed("switch_tool"):
		vehicle_tool_index = (vehicle_tool_index + 1) % vehicle_tools.size()
		set_current_tool(vehicle_tool_index)

	var target_velocity: float = 0.0
	if Input.is_action_pressed("gripper_open"):
		target_velocity = -1.0

		if vehicle_tools[vehicle_tool_index] is GripperTool:
			vehicle_tools[vehicle_tool_index].release_object()

		# TODO: Indicate sound on the tool itseft
		sounds.stop("gripper_close")
		sounds.play("gripper_open")
	elif Input.is_action_pressed("gripper_close"):
		target_velocity = 1.0
		sounds.stop("gripper_open")
		sounds.play("gripper_close")
	else:
		sounds.stop("gripper_open")
		sounds.stop("gripper_close")

	vehicle_tools[vehicle_tool_index].move_left(target_velocity)
	vehicle_tools[vehicle_tool_index].move_right(-target_velocity)


func set_current_tool(new_tool_index: int) -> void:
	for i in range(vehicle_tools.size()):
		vehicle_tools[i].set_active(i == new_tool_index)

	vehicle_tool_index = new_tool_index
