extends "res://scripts/delivery/delivery_tool.gd"
class_name MagnetDeliveryTool

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
	if not detected_object:
		return

	if raycast.is_colliding():
		var collision_point: Vector3 = raycast.get_collision_point()
		var collision_normal: Vector3 = raycast.get_collision_normal()
		
		var distance: float = collision_point.distance_to(stickpoint.global_transform.origin)
		if distance <= sticking_distance:
			raycast.enabled = false
#			detected_object.mode = RigidBody.MODE_STATIC
			var old_pos: Vector3 = detected_object.global_transform.origin
			
			detected_object.get_parent().remove_child(detected_object)
			magnet_body.add_child(detected_object)
			
			detected_object.global_transform.origin = old_pos


func _on_body_entered(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return
	
	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return
	
	# Make sure the object is not already in the area
	if detected_object and object.get_instance_id() == detected_object.get_instance_id():
		return
	
	detected_object = object
	raycast.enabled = true


func _on_body_exited(body: Node) -> void:
	# Make sure the body is a Deliverable
	if not body is DeliveryObject:
		return

	var object: DeliveryObject = body

	# Check if the object has the same objective_type
	if not object.is_in_group(group):
		return
	
	# Make sure the object is not already in the area
	if detected_object and object.get_instance_id() == detected_object.get_instance_id():
		return
	
	raycast.enabled = false
	detected_object = null
