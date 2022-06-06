extends "res://scripts/sounds/sounds.gd"


func _ready() -> void:
	._ready()
	sound_player = load("res://scenes/sounds/RadioSoundPlayer.tscn")


func get_sounds() -> Dictionary:
	return {
		"nice": "res://assets/sounds/radio/01_Nice.wav",
		"good_job": "res://assets/sounds/radio/02_Good_job.wav",
		"congrats": "res://assets/sounds/radio/03_Congrats.wav",
		"drop_item_in_the_net": "res://assets/sounds/radio/04_Drop_item_in_the_net.wav",
		"free_the_animals": "res://assets/sounds/radio/05_Free_the_animals.wav",
		"collect_waste": "res://assets/sounds/radio/06_collect_waste.wav",
		"beware_of_rocks": "res://assets/sounds/radio/07_Beware_of_rocks.wav",
		"boat_started": "res://assets/sounds/radio/08_Boat_started.wav",
		"boat_stopped": "res://assets/sounds/radio/09_Boat_stopped.wav",
		"be_careful_with_algues": "res://assets/sounds/radio/10_Be_careful_with_algues.wav",
		"avoid_the_animals": "res://assets/sounds/radio/11_Avoid_the_animals.wav",
		"take_care_of_plants": "res://assets/sounds/radio/12_Take_care_of_plants.wav",
		"well_done": "res://assets/sounds/radio/13_Well_done.wav",
		"take_care_of_reef": "res://assets/sounds/radio/14_Take_care_of_reef.wav",
		"rope_attached": "res://assets/sounds/radio/15_Rope_attached.wav",
	}
