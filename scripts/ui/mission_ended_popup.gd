extends Popup

const objective_line: PackedScene = preload("res://scenes/ui/objective_line.tscn")

export var title_label_path: NodePath
onready var title_label: Label = get_node(title_label_path)

export var time_label_path: NodePath
onready var time_label: Label = get_node(time_label_path)

export var objectives_list_path: NodePath
onready var objectives_list: VBoxContainer = get_node(objectives_list_path)


func update_time(time: float) -> void:
	time_label.text = MissionTimer.format_time(time)

func update_objectives(objectives: Array) -> void:
	if objectives.size() == 0:
		return
	
	for i in range(objectives.size()):
		var objective: Dictionary = objectives[i]
		
		# Try to get existing line
		var line: ObjectiveLine = null
		if i < objectives_list.get_child_count():
			line = objectives_list.get_child(i)
		
		# Create new line
		if not line:
			line = objective_line.instance()
			objectives_list.add_child(line)
		
		# Assign values
		if objective.has("title"):
			line.title.text = objective.title
		
		if objective.has("value"):
			line.value.text = str(objective.value)


func _on_Restart_pressed() -> void:
	print("restart scene")


func _on_Back_pressed() -> void:
	print("back to main menu")
