extends RigidBody
class_name RopeSection

const LENGTH: float = 0.145

var length: float setget set_length, get_length

var shape: CapsuleShape
var mesh: CapsuleMesh


func _ready() -> void:
	shape = get_node("CollisionShape").shape.duplicate()
	mesh = get_node("MeshInstance").mesh.duplicate()


func set_length(value: float) -> void:
	shape.height = value
	mesh.mid_height = value


func get_length() -> float:
	return shape.height
