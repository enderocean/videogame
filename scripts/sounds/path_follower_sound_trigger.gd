extends Node

export var started_radio_sound: String
export var stopped_radio_sound: String


func _on_path_follower_started() -> void:
	RadioSounds.play(started_radio_sound)


func _on_path_follower_stopped() -> void:
	RadioSounds.play(stopped_radio_sound)
