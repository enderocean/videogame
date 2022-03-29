extends Popup

const objective_line: PackedScene = preload("res://scenes/ui/objective_line.tscn")

export var title_path: NodePath
onready var title: Label = get_node(title_path)

export var time_path: NodePath
onready var time: Label = get_node(time_path)

export var objectives_path: NodePath
onready var objectives: VBoxContainer = get_node(objectives_path)

