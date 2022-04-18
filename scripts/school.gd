extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(5.0), "timeout")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	pass

	var school = get_node("/School");
	
	for i in range(multimesh.instance_count):
		var position = multimesh.get_instance_transform(i)
		position = position.translated(Vector3(0,0,-0.02))
		multimesh.set_instance_transform(i, position)

		# var position = Transform()
		# position = position.translated(Vector3(randf() * 100 - 50, randf() * 50 - 25, randf() * 50 - 25))
		# print(position)
		# multimesh.set_instance_transform(i, position)
