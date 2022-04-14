extends Control
class_name MissionPanel

export var thumbnail_path: NodePath
onready var thumbnail: TextureRect = get_node(thumbnail_path)

export var country_path: NodePath
onready var country: Label = get_node(country_path)

export var location_path: NodePath
onready var location: Label = get_node(location_path)

export var description_path: NodePath
onready var description: RichTextLabel = get_node(description_path)

export var objective_path: NodePath
onready var objective: RichTextLabel = get_node(objective_path)

export var tools_path: NodePath
onready var tools: RichTextLabel = get_node(tools_path)

func show_mission(level_data: LevelData) -> void:
	if level_data.thumbnail:
		thumbnail.texture = load(level_data.thumbnail)
	
	country.text = level_data.country
	location.text = level_data.location
	description.bbcode_text = level_data.description
	
	objective.bbcode_text = "Objective:\n"
	for text in level_data.objectives:
		objective.bbcode_text += " - " + text + "\n"
	
	tools.bbcode_text = "Tools: "
	for i in range(level_data.tools.size()):
		tools.bbcode_text += level_data.tools[i]
		
		if i < level_data.tools.size() - 1:
			tools.bbcode_text += ", "
