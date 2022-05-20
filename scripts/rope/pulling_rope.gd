extends "res://scripts/rope/rope.gd"

export var destination_path: NodePath
var destination: Spatial

export(float, 0.1, 100) var pulling_speed: float = 10.0

var anchor: PhysicsBody
var pulling: bool = false

signal pulled

func _ready() -> void:
	destination = get_node(destination_path)
	
	var from_node = get_node_or_null(from)
	if not from_node:
		return
	
	# Connect to the catched event of the delivery tool to make the rope pull
	if from_node is DeliveryTool:
		from_node.connect("catched", self, "_on_delivery_tool_catched")


func _physics_process(delta: float) -> void:
	if destination and pulling:
		if to_body.global_transform.origin.distance_to(destination.global_transform.origin) < RopeSection.LENGTH:
			pulling = false
			emit_signal("pulled")
		
		to_body.global_transform.origin = lerp(to_body.global_transform.origin, destination.global_transform.origin, delta * pulling_speed)


func _on_delivery_tool_catched() -> void:
	pull()


func pull() -> void:
	pulling = true


