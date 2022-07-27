extends Popup
class_name CollectiblePopup

export var title_path: NodePath
onready var title: Label = get_node(title_path)
export var description_path: NodePath
onready var description: RichTextLabel = get_node(description_path)
export var image_path: NodePath
onready var image: TextureRect = get_node(image_path)


func _on_Continue_pressed() -> void:
	hide()

