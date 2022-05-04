extends MultiMeshInstance

var random: RandomNumberGenerator = RandomNumberGenerator.new()

export var margin: float = 1.0
export var range_count: Vector2 = Vector2(1, 20)
export var range_position: Vector2 = Vector2(1, 20)

func _ready() -> void:
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.COLOR_8BIT
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_8BIT
	multimesh.instance_count = random.randi_range(range_count.x, range_count.y)

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

## Fish shader from addon
#tool
#extends MultiMeshInstance
#
#var random: RandomNumberGenerator = RandomNumberGenerator.new()
#
#export var margin: float = 1.0
#export var range_count: Vector2 = Vector2(1, 20)
#export var range_position: Vector2 = Vector2(1, 20)
#
#export (float) var frequency = 5 setget refresh_frequency
#export (float, -6.28, 6.28) var fish_twist_frequency = -5 setget refresh_twist_frequency
#export (float, -20, 20) var fish_s_frequency = 5 setget refresh_s_frequency
#
#export (float, -2, 2) var fish_translatex = 0 setget refresh_translate_x
#export (float, -2, 2) var fish_translatey = 0 setget refresh_translate_y
#export (float, -2, 2) var fish_translatez = 0 setget refresh_translate_z
#
#export (float, -1.5, 1.5) var fish_yaw = 0 setget refresh_yaw
#
#export (float, -1.5, 1.5) var fish_twist = 0 setget refresh_twist
#export (float, -1.5, 1.5) var fish_s = 0 setget refresh_s
#
#export (float, -10, 10) var fish_head_z = -1 setget refresh_head_z
#export (float, -10, 10) var fish_tail_z = 1 setget refresh_tail_z
#
#export (Color) var fish_head_color = Color(0,0,0) setget refresh_head_color
#export (Color) var fish_tail_color = Color(1,1,1) setget refresh_tail_color
#
#var fish_translate = Vector3()
#var timer = 0
#
#func refresh_head_z( v ):
#	fish_head_z = v
#	update_shader()
#
#func refresh_tail_z( v ):
#	fish_tail_z = v
#	update_shader()
#
#func refresh_head_color( v ):
#	fish_head_color = v
#	update_shader()
#
#func refresh_tail_color( v ):
#	fish_tail_color = v
#	update_shader()
#
#func refresh_yaw( v ):
#	fish_yaw = v
#	update_shader()
#
#func refresh_s_frequency( v ):
#	fish_s_frequency = v
#	update_shader()
#
#func refresh_s( v ):
#	fish_s = v
#	update_shader()
#
#func refresh_twist_frequency( v ):
#	fish_twist_frequency = v
#	update_shader()
#
#func refresh_twist( v ):
#	fish_twist = v
#	update_shader()
#
#func refresh_frequency( v ):
#	frequency = v
#	update_shader()
#
#func refresh_translate_x( v ):
#	refresh_translate( Vector3( v, fish_translate.y, fish_translate.z ) )
#
#func refresh_translate_y( v ):
#	refresh_translate( Vector3( fish_translate.x, v, fish_translate.z ) )
#
#
#func refresh_translate_z( v ):
#	refresh_translate( Vector3( fish_translate.x, fish_translate.y, v ) )
#
#
#func refresh_translate( v ):
#	fish_translate = v;
#	fish_translatex = fish_translate.x
#	fish_translatey = fish_translate.y
#	fish_translatez = fish_translate.z
#	update_shader()
#
#func update_shader():
#	multimesh.mesh.get_surface_material(0).set_shader_param( "frequency", frequency )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "translate", fish_translate )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "yaw_factor", fish_yaw )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "twist_factor", fish_twist )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "twist_factor_frequency", fish_twist_frequency )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "s_factor", fish_s )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "s_factor_frequency", fish_s_frequency )
#
#	multimesh.mesh.get_surface_material(0).set_shader_param( "head_z", fish_head_z )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "head_color", fish_head_color )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "tail_z", fish_tail_z )
#	multimesh.mesh.get_surface_material(0).set_shader_param( "tail_color", fish_tail_color )
#
#func fixed_process(delta):
#	print( "fixed_process" )
#	timer += delta
#	multimesh.mesh.get_surface_material(0).set_shader_param( "timer", timer )
##	update_shader()
#
#func _process(delta):
#	timer += delta
#	multimesh.mesh.get_surface_material(0).set_shader_param( "timer", timer )
##	update_shader()
#
#func _ready():
#	multimesh.transform_format = MultiMesh.TRANSFORM_3D
#	multimesh.color_format = MultiMesh.COLOR_8BIT
#	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_8BIT
#	multimesh.instance_count = random.randi_range(range_count.x, range_count.y)
#
#	var meshes_positions: PoolVector3Array
#	for i in range(multimesh.instance_count):
#		var position: Transform
#		position = position.translated(
#			(
#				global_transform.origin
#				+ Vector3(
#					random.randf_range(range_position.x, range_position.y),
#					random.randf_range(range_position.x, range_position.y),
#					random.randf_range(range_position.x, range_position.y)
#				)
#			)
#		)
#
#		multimesh.set_instance_transform(i, position)
#		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))
#
#		meshes_positions.append(position.origin)
#
#		update_shader()
#		set_process(true)
