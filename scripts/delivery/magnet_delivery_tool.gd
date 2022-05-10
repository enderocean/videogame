extends "res://scripts/delivery/delivery_tool.gd"
class_name MagnetDeliveryTool

export var stickpoint_path: NodePath
onready var stickpoint: Position3D = get_node(stickpoint_path)

export var raycast_path: NodePath
onready var raycast: RayCast = get_node(raycast_path)

export var sticking_distance: float = 0.01
export var sticking_speed: float = 1.0

var detected_object: DeliveryObject
var sticked: bool = false


func _ready() -> void:
	objective_type = Globals.ObjectiveType.MAGNET
	group = "objective_%s" % str(objective_type).to_lower()


func _physics_process(delta: float) -> void:
	if not detected_object or sticked:
		return

	if not raycast.is_colliding():
		return
	
	var collision_point: Vector3 = raycast.get_collision_point()
	var collision_normal: Vector3 = raycast.get_collision_normal()
	var distance: float = collision_point.distance_to(stickpoint.global_transform.origin)
	print(distance)
	if distance <= sticking_distance:
#		mode = RigidBody.MODE_STATIC
		
#		look_at(global_transform.origin - collision_normal, Vector3.UP);
		
		raycast.enabled = false
		sticked = true
		
		detected_object.delivered = true


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

	# Make the object delivered
	print("Magnet stick to: ", detected_object.name)


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
