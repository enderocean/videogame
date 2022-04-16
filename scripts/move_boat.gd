extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point = Vector3(0,-5,120)


# Called when the node enters the scene tree for the first time.
func _process(delta):
	yield(get_tree().create_timer(5.0), "timeout")
	var direction = (point - transform.origin)/200
	move_and_slide(direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
