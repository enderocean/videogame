extends Control
class_name MissionPanel

export var thumbnail_path: NodePath
onready var thumbnail: TextureRect = get_node(thumbnail_path)

export var country_path: NodePath
onready var country: Label = get_node(country_path)

export var place_path: NodePath
onready var place: Label = get_node(place_path)

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
	place.text = level_data.place
	description.text = level_data.description
	
	objective.text = "Objective:\n"
	for text in level_data.objectives:
		objective.text += " - " + text + "\n"
	
	tools.text = "Tools: "
	for text in level_data.tools:
		tools.text += text + ", "
