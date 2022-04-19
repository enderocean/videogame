extends AudioStreamPlayer

var tween: Tween


func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")


func _on_tween_all_completed() -> void:
	stop()


# Fade the volume of the AudioPlayer before stopping it
func stop_fade():
	# Set the tween duration to the remaining time of the sound being played
	var duration: float = stream.get_length() - get_playback_position()
	if duration <= 0:
		stop()
		return

	tween.interpolate_property(self, "volume_db", volume_db, -80, duration)
	tween.start()
