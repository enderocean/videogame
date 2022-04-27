extends Area
class_name SoundTriggerArea
# Trigger any sound when the ROV enter the area

export var sound_key: String = ""
export var once: bool = true

var triggered: bool = false


func _on_body_entered(body: Node) -> void:
	if sound_key.empty():
		printerr(name, " doesn't have a sound key assigned")
		return
	
	if not RadioSounds.get_sounds().has(sound_key):
		printerr("The sound key of ", name ,": '", sound_key, "' was not found")
		return
		
	if once and triggered:
		return

	triggered = true
	RadioSounds.play(sound_key)
