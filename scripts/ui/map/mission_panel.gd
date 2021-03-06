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

export var start_button_path: NodePath
onready var start_button: Button = get_node(start_button_path)

export var account_state_label_path: NodePath
onready var account_state_label: Label = get_node(account_state_label_path)


func _ready() -> void:
	if SaveManager.user.empty():
		account_state_label.text = tr("YOU_ARE_NOT_CONNECTED")
		return
	
	account_state_label.text = tr("YOU_ARE_CONNECTED").format({"username": SaveManager.user.username})


func show_mission(level_data: LevelData, can_start: bool) -> void:
	if level_data.thumbnail:
		thumbnail.texture = load(level_data.thumbnail)
	
	country.text = tr(level_data.country)
	location.text = tr(level_data.location)
	description.bbcode_text = tr(level_data.description)
	
	objective.bbcode_text = tr("OBJECTIVES") + ":\n"
	for text in level_data.objectives:
		objective.bbcode_text += " - " + tr(text) + "\n"
	
	tools.bbcode_text = tr("TOOLS") + ": "
	for i in range(level_data.tools.size()):
		tools.bbcode_text += tr(level_data.tools[i])

		if i < level_data.tools.size() - 1:
			tools.bbcode_text += ", "

	start_button.disabled = not can_start
