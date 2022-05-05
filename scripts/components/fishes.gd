extends MultiMeshInstance

var random: RandomNumberGenerator = RandomNumberGenerator.new()

export var margin: float = 1.0
export var count: int = 20
export var range_position: Vector2 = Vector2(1, 20)

onready var material: ShaderMaterial = multimesh.mesh.surface_get_material(0)

func _ready() -> void:
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.COLOR_8BIT
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_8BIT
	multimesh.instance_count = count

	var meshes_positions: PoolVector3Array
	for i in range(multimesh.instance_count):
		var position: Transform
		position = position.translated(
			(
				global_transform.origin
				+ Vector3(
					random.randf_range(range_position.x, range_position.y),
					random.randf_range(range_position.x, range_position.y),
					random.randf_range(range_position.x, range_position.y)
				)
			)
		)
		
		multimesh.set_instance_transform(i, position)
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))

		meshes_positions.append(position.origin)


func _physics_process(delta: float) -> void:
	material.set_shader_param("time_scale", 1)
