extends Control

export var collectible_button_scene: PackedScene

export var grid_container_path: NodePath
onready var grid_container: GridContainer = get_node(grid_container_path)

export var sidebar_path: NodePath
onready var sidebar: Control = get_node(sidebar_path)

export var collectible_panel_path: NodePath
onready var collectible_panel: Control = get_node(collectible_panel_path)

export var locked_label_path: NodePath
onready var locked_label: Control = get_node(locked_label_path)

export var unlocked: Color = Color.white
export var locked: Color = Color.black


func _ready() -> void:
	sidebar.visible = false
	for collectible_id in Globals.collectibles:
		var collectible: CollectibleData = Globals.collectibles[collectible_id]
		var collectible_button: Button = collectible_button_scene.instance()
		grid_container.add_child(collectible_button)
		
		collectible_button.connect("pressed", self, "_on_collectible_pressed", [collectible_id])
		
		if collectible.image.empty():
			printerr("No image defined for collectible: ", collectible.id)
			continue
		collectible_button.image.texture = load(collectible.image)
		collectible_button.image.self_modulate = unlocked if SaveManager.collectibles.has(collectible_id) else locked


func _on_collectible_pressed(collectible_id: String) -> void:
	sidebar.visible = true
	var unlocked: bool = SaveManager.collectibles.has(collectible_id)
	collectible_panel.visible = unlocked
	locked_label.visible = not unlocked
	
	if unlocked:
		var collectible: CollectibleData = Globals.collectibles[collectible_id]
		collectible_panel.image.texture = load(collectible.image)
		collectible_panel.title.text = tr(collectible.title)
		collectible_panel.description.bbcode_text = tr(collectible.description)


func _on_close_pressed() -> void:
	hide()
