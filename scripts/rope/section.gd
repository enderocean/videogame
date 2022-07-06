extends RigidBody
class_name RopeSection

const LENGTH: float = 0.145

var length: float setget set_length, get_length
#var buoyancy = mass * (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale)
var buoyancy = mass * 0.25
var collision_shape: CollisionShape
var mesh_instance: MeshInstance


func _ready() -> void:
	add_to_group("buoyant")
	collision_shape = get_node("CollisionShape")
	mesh_instance = get_node("MeshInstance")
	# Making shape and mesh unique for each section because each have a different size
	collision_shape.shape = collision_shape.shape.duplicate()
	mesh_instance.mesh = mesh_instance.mesh.duplicate()


func set_length(value: float) -> void:
	collision_shape.shape.height = value
	mesh_instance.mesh.mid_height = value


func get_length() -> float:
	return collision_shape.shape.height
