extends Spatial

export var vehicle_path: NodePath
onready var vehicle: Spatial = get_node(vehicle_path)

func _process(_delta: float) -> void:
	var distance = self.global_transform.origin - vehicle.global_transform.origin
	var length = distance.length()
	if length > 5:
		self.global_transform.origin = vehicle.global_transform.origin + distance * 5 / length
	self.look_at(vehicle.global_transform.origin, Vector3.UP)
