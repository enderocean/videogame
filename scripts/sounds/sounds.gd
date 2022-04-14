extends Node

export var sound_player: PackedScene

onready var sounds: Dictionary = get_sounds()

var rand: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rand.randomize()


# Play a sound with the key in the sounds dictionary
func play(key: String) -> void:
	if not sounds.has(key):
		return

	var player: AudioStreamPlayer = sound_player.instance()

	# Indicated an array of multiple sounds for a key
	if sounds[key] is Array:
		# Select random sound from array
		player.stream = load(sounds[key][rand.randi() % sounds[key].size()])

	# Only one sound for the key
	else:
		player.stream = load(sounds[key])

	add_child(player)
	player.play()


# Stops currently playing sounds
func stop() -> void:
	var players: Array = get_children()

	if players.size() == 0:
		return

	for player in players:
		player.stop()


func get_sounds() -> Dictionary:
	return {}
