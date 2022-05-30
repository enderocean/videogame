extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if (self.name == 'BottleNoseDolphin'):
		$AnimationPlayer.playback_speed = 0.8
	else:
		if (self.name == 'BottleNoseDolphin2'):
			$AnimationPlayer.playback_speed = 0.6
		else:
			$AnimationPlayer.playback_speed = 0.7
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimationPlayer.play("Swim1")
