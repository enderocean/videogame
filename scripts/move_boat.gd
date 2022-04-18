extends KinematicBody

onready var playback_position: float
onready var moving: bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point = Vector3(0,-5,250)

func _ready():
	
	var msg_boat_started = get_node("../BoatStarted")

	if (!msg_boat_started.playing):
		playback_position = msg_boat_started.get_playback_position();
		msg_boat_started.play(playback_position);


# Called when the node enters the scene tree for the first time.
func _process(delta):

	var direction = (point - transform.origin)/400
	move_and_slide(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
