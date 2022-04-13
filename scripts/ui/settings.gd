extends PanelContainer
class_name SettingsPanel

export var physics_rate_path: NodePath = "VBoxContainer/physicsRate"
export var physics_rate_slider_path: NodePath = "VBoxContainer/physicsRateSlider"

onready var physics_rate: Label = get_node(physics_rate_path)
onready var physics_rate_slider: Slider = get_node(physics_rate_slider_path)


func _ready() -> void:
	if Globals.isHTML5:
		Globals.physics_rate = 60
	else:
		Globals.physics_rate = 200

	physics_rate.text = "Physics: %s Hz" % Globals.physics_rate
	physics_rate_slider.value = Globals.physics_rate


func _on_HSlider_value_changed(value) -> void:
	Globals.physics_rate = value
	physics_rate.text = "Physics: %s Hz" % Globals.physics_rate


func _on_godrayToggle_toggled(button_pressed: bool) -> void:
	Globals.enable_godray = button_pressed
#	$Godrays.emitting = button_pressed


func _on_dirtparticlesToggle_toggled(button_pressed: bool) -> void:
#	$SuspendedParticleHolder/SuspendedParticles.emitting = button_pressed
	pass


func _on_fancyWaterToggle_toggled(button_pressed: bool) -> void:
	Globals.fancy_water = button_pressed
