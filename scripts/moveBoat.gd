extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point = Vector3(0,0,120)




# Called when the node enters the scene tree for the first time.
func _process(delta):
	var direction = (point - transform.origin)/100
	move_and_slide(direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
