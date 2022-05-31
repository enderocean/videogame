extends Node
class_name TrapAnimal

signal animal_free

export var fish_net_path: NodePath = ""
onready var fish_net: Spatial = get_node(fish_net_path)

export var path_follow_path: NodePath = ""
onready var path_follow: PathFollow = get_node(path_follow_path)

export var speed: float = 1
export var dist_tofinish: float = 50

func _ready() -> void:
	set_physics_process(false)
	add_to_group("objectives_nodes")
# warning-ignore:return_value_discarded
	fish_net.connect("net_removed", self, "_on_net_removed")

func _on_net_removed() -> void:
	$AnimationPlayer.play("ArmatureAction")
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	path_follow.offset += delta * speed
	if (path_follow.offset >= dist_tofinish):
		emit_signal("animal_free", [self])
		set_physics_process(false)
	
