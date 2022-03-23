extends Timer
class_name MissionTimer

export var minutes: int = 15
export var label_path: NodePath
onready var label: Label = get_node_or_null(label_path)


func _ready() -> void:
# warning-ignore:return_value_discarded
	connect("timeout", self, "_on_timeout")

	# Ensure the timer doesn't restart itself
	one_shot = true
	autostart = false
	# Start the timer with the given minutes
	start(minutes * 60)


func _physics_process(_delta: float) -> void:
	if not label:
		return
	
	label.text = format_time(time_left)


func _on_timeout() -> void:
	print("Mission timed out")


static func format_time(time_sec: float) -> String:
	var secs = int(time_sec) % 60
	var mins = int(time_sec / 60) % 60
	var hours = int(time_sec / 60) / 60
	
	if hours >= 1:
		return "%02d:%02d:%02d" % [hours, mins, secs]
	else:
		return "%02d:%02d" % [mins, secs]
