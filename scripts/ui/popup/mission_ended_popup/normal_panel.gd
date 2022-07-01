extends Panel

const objective_line: PackedScene = preload("res://scenes/ui/objective_line.tscn")

export var title_label_path: NodePath
var title_label: Label

export var time_label_path: NodePath
var time_label: Label

export var objectives_list_path: NodePath
var objectives_list: VBoxContainer

export var stars_path: NodePath
var stars: HBoxContainer

export var back_to_missions_button_path: NodePath
var back_to_missions_button: Button


func _ready() -> void:
	title_label = get_node(title_label_path)
	time_label = get_node(time_label_path)
	stars = get_node(stars_path)
	objectives_list = get_node(objectives_list_path)
	back_to_missions_button = get_node(back_to_missions_button_path)
	
	# Make stars materials unique
	for star in stars.get_children():
		var material: ShaderMaterial = star.material
#		star.material.shader = material.shader.duplicate() 
		star.material = star.material.duplicate()


func update_stars(score: int, stars_enabled: bool) -> void:
	stars.visible = stars_enabled
	
	if not stars_enabled:
		return
	
	var score_stars: float = score / 1000.0
	for i in range(stars.get_child_count()):
		var star: TextureRect = stars.get_child(i)
		var cut_value: float = 1.0
		# Set the cut value of a star in case the stars score is not a plain value (e.g 2.5 stars)
		if (i + 1) > score_stars:
			cut_value = 1.0 - clamp((float(i + 1) - score_stars), 0.0, 1.0)

		star.material.set_shader_param("cut", cut_value)


func update_time(time: float) -> void:
	time_label.text = MissionTimer.format_time(time)


func update_objectives(objectives: Dictionary, objectives_progress: Dictionary) -> void:
	if objectives.size() == 0:
		return

	for i in range(objectives.keys().size()):
		# Try to get existing line
		var line: ObjectiveLine = null
		if i < objectives_list.get_child_count():
			line = objectives_list.get_child(i)

		# Create new line
		if not line:
			line = objective_line.instance()
			objectives_list.add_child(line)
		
		# Set the progress of the objective
		var value: int = 0
		if objectives_progress.has(objectives.keys()[i]):
			value = objectives_progress.get(objectives.keys()[i])
		
		line.title.text = Localization.get_objective_text(objectives.keys()[i])
		line.value.text = "%s / %s" % [value, objectives.values()[i]]
