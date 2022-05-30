extends VBoxContainer

export var image_path: NodePath = "Image"
export var title_path: NodePath = "Title"
export var description_path: NodePath = "Description"

onready var image: TextureRect = get_node(image_path)
onready var title: Label = get_node(title_path)
onready var description: RichTextLabel = get_node(description_path)
