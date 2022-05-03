extends Camera2D
class_name MapCamera

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
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		move_camera = event.is_pressed()
	
	elif event is InputEventMouseMotion and move_camera:
		# Stop the tween in case we are moving and don't want to click any point
		tween.stop_all()
		
		var limit: Vector2 = Vector2(
			world_sprite_size.x / 2,
			world_sprite_size.y / 2
		)
		
		# Move the camera
		position -= event.relative
		
		# Make sure the camera stay in bounds of the World sprite
		if position.x >= limit.x:
			position.x = limit.x
		elif position.x <= -limit.x:
			position.x = -limit.x
		
		if position.y >= limit.y:
			position.y = limit.y
		elif position.y <= -limit.y:
			position.y = -limit.y


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
	tween.start()
	can_move = false


func _on_tween_all_completed() -> void:
	can_move = true
