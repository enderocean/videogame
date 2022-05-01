extends Area

class_name AreaRope

var rope_id

func _ready():
	pass # Replace with function body.

func set_rope(soft_rope, rope_nb):
	rope_id = rope_nb
	var collision_shape = CollisionShape.new()
	collision_shape.shape = soft_rope.mesh.create_convex_shape()
	add_child(collision_shape)
