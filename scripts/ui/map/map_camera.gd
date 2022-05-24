extends Camera2D
class_name MapCamera

export var zoom_min: float = 0.5
export var zoom_max: float = 1.0
export(float, 0.0, 1.0) var zoom_factor: float = 0.1
var zoom_level: float = 1.0 setget _set_zoom_level

export var duration: float = 0.5

onready var world_sprite: Sprite = get_parent()
onready var world_sprite_size: Vector2 = world_sprite.texture.get_size()

onready var tween: Tween = Tween.new()

var move_camera: bool = false
var can_move: bool = false

func _ready() -> void:
	add_child(tween)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")


func _input(event: InputEvent) -> void:
	if not can_move:
		move_camera = false
		return
	
	# TODO: Change this with the Input Map for controller support
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				move_camera = event.is_pressed()
			BUTTON_WHEEL_UP:
				_set_zoom_level(zoom_level - zoom_factor)
			BUTTON_WHEEL_DOWN:
				_set_zoom_level(zoom_level + zoom_factor)
		
	elif event is InputEventMouseMotion and move_camera:
		# Stop the tween in case we are moving and don't want to click any point
		tween.stop_all()
		
		var limit: Vector2 = Vector2(
			world_sprite_size.x / 2,
			world_sprite_size.y / 2
		)
		
		# Move the camera
		position -= event.relative * zoom_level
		
		# Make sure the camera stay in bounds of the World sprite
		if position.x >= limit.x:
			position.x = -limit.x + (position.x - limit.x)
		elif position.x <= -limit.x:
			position.x = limit.x - (position.x + limit.x)
		
		if position.y >= limit.y:
			position.y = limit.y
		elif position.y <= -limit.y:
			position.y = -limit.y


func _set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, zoom_min, zoom_max)
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(zoom_level, zoom_level),
		duration / 2,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	tween.start()


func goto(mission_point: MissionPoint) -> void:
	tween.interpolate_property(
		self,
		"position",
		position,
		get_parent().to_local(mission_point.position),
		duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "zoom", zoom, mission_point.zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	zoom_level = mission_point.zoom.x
	tween.start()
	can_move = false


func _on_tween_all_completed() -> void:
	can_move = true
