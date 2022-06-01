extends ColorRect
class_name VignetteEffect

export var duration: float = 1.0
export var wait_between: float = 1.0

var tween: Tween = null
var timer: Timer = null

func start() -> void:
# warning-ignore:return_value_discarded
	tween.interpolate_property(material, "shader_param/vignette_intensity", 0.0, 1.0, duration / 2.0, Tween.TRANS_EXPO)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween, "tween_all_completed")
	timer.start(wait_between)
	yield(timer, "timeout")
# warning-ignore:return_value_discarded
	tween.interpolate_property(material, "shader_param/vignette_intensity", 1.0, 0.0, duration / 2.0, Tween.TRANS_SINE)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween, "tween_all_completed")


func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
