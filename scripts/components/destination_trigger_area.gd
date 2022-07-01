extends Area
class_name DestinationTriggerArea
# Trigger a destination event

var triggered: bool = false

signal arrived(node)


func _ready() -> void:
	add_to_group("objectives_nodes")


func _on_body_entered(body: Node) -> void:
	if triggered:
		return
	
	triggered = true
	emit_signal("arrived", self)
