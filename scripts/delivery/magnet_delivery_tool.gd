extends "res://scripts/delivery/delivery_tool.gd"
class_name MagnetDeliveryTool

<<<<<<< HEAD
export var magnet_body_path: NodePath
onready var magnet_body: RigidBody = get_node(magnet_body_path)

export var stickpoint_path: NodePath
onready var stickpoint: Position3D = get_node(stickpoint_path)

export var raycast_path: NodePath
onready var raycast: RayCast = get_node(raycast_path)

export var sticking_distance: float = 0.01
export var magnet_force: float = 1.0

var detected_object: DeliveryObject
var sticked: bool = false
var joint: HingeJoint


func _ready() -> void:
	objective_type = Globals.ObjectiveType.MAGNET
	group = "objective_%s" % str(objective_type).to_lower()


func _physics_process(delta: float) -> void:
	if not detected_object or carried:
		return

	if raycast.is_colliding():
		var collision_point: Vector3 = raycast.get_collision_point()
		var collision_normal: Vector3 = raycast.get_collision_normal()
		
		var distance: float = collision_point.distance_to(stickpoint.global_transform.origin)
		if distance <= sticking_distance:
			raycast.enabled = false
			detected_object.mass = 1.0
			
			var joint: HingeJoint = HingeJoint.new()
			joint.set_param(HingeJoint.PARAM_BIAS, 1.0)
			joint.set_flag(HingeJoint.FLAG_USE_LIMIT, true)
			joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, 0.0)
			joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, 0.0)
			add_child(joint)
			
			joint.global_transform.origin = collision_point
			joint.set_node_a(magnet_body.get_path())
			joint.set_node_b(detected_object.get_path())
			
			emit_signal("catched")
=======
export var area: NodePath

var detected_object: DeliveryObject

func _ready() -> void:
	.ready()
	objective_type = Globals.ObjectiveType.MAGNET
	(get_node(area) as Area).connect("area_entered", self, "_on_body_entered")
>>>>>>> 6d9f676 (Started delivery tools)


func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable
<<<<<<< HEAD
	if not body is DeliveryObject:
		return
	
=======

	if not body is DeliveryObject:
		return

>>>>>>> 6d9f676 (Started delivery tools)
	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return
<<<<<<< HEAD
	
	# Make sure the object is not already in the area
	if detected_object and object.get_instance_id() == detected_object.get_instance_id():
		return
	
	detected_object = object
	raycast.enabled = true


func _on_body_exited(body: Node) -> void:
=======

	# Make sure the object is not already in the area
	var id: int = object.get_instance_id()
	if objects.has(id):
		return

	# Don't play a radio sound for the vacuum
	if objective_type != Globals.ObjectiveType.VACUUM:
		# Play random sound from array
		RadioSounds.play(RADIO_SOUNDS[RadioSounds.rand.randi_range(0, RADIO_SOUNDS.size() - 1)])

	# Make the object delivered
	object.delivered = true
	objects.append(id)
	emit_signal("objects_changed", self, objects)


func _on_body_exited(body: Node) -> void:
	if only_enter:
		return
	
>>>>>>> 6d9f676 (Started delivery tools)
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return

<<<<<<< HEAD
	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return
	
	# Make sure the object is not already in the area
	if detected_object and object.get_instance_id() == detected_object.get_instance_id():
		return
	
	raycast.enabled = false
	detected_object = null
=======
	# Make sure the object is in the area
	var object: DeliveryObject = body
	var id: int = object.get_instance_id()
	var index: int = objects.find(id)
	if index == -1:
		return

	# Make the object not delivered
	object.delivered = false
	objects.remove(index)
	emit_signal("objects_changed", self, objects)
>>>>>>> 6d9f676 (Started delivery tools)
