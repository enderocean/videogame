extends PanelContainer

export var physics_rate_path: NodePath = "VBoxContainer/physicsRate"
export var physics_rate_slider_path: NodePath = "VBoxContainer/physicsRateSlider"

onready var physics_rate: Label = get_node(physics_rate_path)
onready var physics_rate_slider: Slider = get_node(physics_rate_slider_path)


func _ready() -> void:
	if Globals.isHTML5:
		Globals.physics_rate = 60
	else:
		Globals.physics_rate = 200

	Engine.iterations_per_second = Globals.physics_rate
	physics_rate.text = "Physics: %s Hz" % Globals.physics_rate
	physics_rate_slider.value = Globals.physics_rate


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not self.is_visible():
			self.show()
		else:
			self.hide()


func _on_HSlider_value_changed(value):
	Globals.physics_rate = value
	Engine.iterations_per_second = value
	physics_rate.text = "Physics: %s Hz" % Globals.physics_rate
