extends AudioStreamPlayer

var key: String
var restart: bool = false

signal finished_with_key(key)

func _on_finished() -> void:
	emit_signal("finished_with_key", key)

	# # If marked as restart means looping
	# if restart:
	# 	play()
	# 	return

	# queue_free()
