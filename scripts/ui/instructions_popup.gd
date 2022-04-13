extends Popup
class_name InstructionsPopup

export var title_path: NodePath
onready var title: Label = get_node(title_path)
export var description_path: NodePath
onready var description: RichTextLabel = get_node(description_path)


func _on_Go_pressed() -> void:
	hide()
