extends Camera2D
class_name MapCamera

export var duration: float = 0.5
export var limits_margin: Vector2 = Vector2(500, 0)

export var world_path: NodePath
onready var world_sprite: Sprite = get_node(world_path)
onready var world_sprite_size: Vector2 = world_sprite.texture.get_size()

onready var tween: Tween = Tween.new()

var move_camera: bool = false
var can_move: bool = false

func _ready() -> void:
	add_child(tween)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")


func _input(event: InputEvent) -> void:
	if can_move:
		move_camera = false
		return
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		move_camera = event.is_pressed()
	
	elif event is InputEventMouseMotion and move_camera:
		var limit: Vector2 = Vector2(
			(world_sprite.position.x + world_sprite_size.x * world_sprite.scale.x - limits_margin.x) * zoom.x,
			(world_sprite.position.y + world_sprite_size.y * world_sprite.scale.y - limits_margin.y) * zoom.y
		)
		print(limit)
		
		if position.x >= limit.x:
			position.x = limit.x
		elif position.x <= -limit.x:
			position.x = -limit.x
		if position.y >= limit.y:
			position.y = limit.y
		elif position.y <= -limit.y:
			position.y = -limit.y
		
		tween.stop_all()
		position -= event.relative


func goto(mission_point: MissionPoint) -> void:
	tween.interpolate_property(
		self,
		"position",
		position,
		mission_point.position,
		duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "zoom", zoom, mission_point.zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	tween.start()
	can_move = true


func _on_tween_all_completed() -> void:
	can_move = false
