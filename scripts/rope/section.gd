extends RigidBody
class_name RopeSection

const LENGTH: float = 0.145

var length: float setget set_length, get_length



var collision_shape: CollisionShape
var mesh_instance: MeshInstance

#var mesh: CapsuleMesh
#var shape: CapsuleShape


func _ready() -> void:
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
