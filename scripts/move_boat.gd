extends KinematicBody

export var speed: float = 1.0
export var boat_path: NodePath

var path_points: PoolVector3Array
var path_index: int = 0

var moving: bool = false
var velocity: Vector3 = Vector3.ZERO

signal started
signal stopped

func _ready():
	var path: Path = get_node(boat_path)
	path_points = path.curve.get_baked_points()
	
	yield(get_tree().create_timer(.5), "timeout")
	start()


func _physics_process(delta: float) -> void:
	if not moving:
		return
	
	var target: Vector3 = path_points[path_index]
	target.y = global_transform.origin.y

	var distance: float = global_transform.origin.distance_to(target)
	if global_transform.origin.distance_to(target) < 1.0:
		if path_index + 1 > path_points.size() - 1:
			stop()
			return

		path_index = wrapi(path_index + 1, 0, path_points.size() - 1)
		target = path_points[path_index]

	var direction: Vector3 = (target - global_transform.origin)
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	
	# Quick fix for today
	if velocity == Vector3.ZERO:
		stop()


func start() -> void:
	moving = true
	emit_signal("started")
	RadioSounds.play("boat_started")


func stop() -> void:
	moving = false
	emit_signal("stopped")
	RadioSounds.play("boat_stopped")
