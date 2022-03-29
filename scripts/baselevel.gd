extends Control

onready var mission_ended_popup: Popup = get_node("MissionEndedPopup")
onready var mission_timer: MissionTimer = get_node("MissionTimer")

var active_level: Level


func _ready():
	active_level = load(Globals.active_level).instance()
	add_child(active_level)
	active_level.connect("finished", self, "_on_level_finished")


func _on_level_finished() -> void:
	mission_timer.paused = true
	show_popup()


func _on_MissionTimer_timeout() -> void:
	show_popup()


func show_popup() -> void:
	mission_ended_popup.update_objectives(active_level.objectives)
	mission_ended_popup.update_time(mission_timer.time_left)
	mission_ended_popup.show()
