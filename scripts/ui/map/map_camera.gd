extends Camera2D
class_name MapCamera

export var duration: float = 0.5

onready var tween: Tween = Tween.new()

func _ready() -> void:
	add_child(tween)

func goto(mission_point: MissionPoint) -> void:
	tween.interpolate_property(self, "position", position, mission_point.position, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "zoom", zoom, mission_point.zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

