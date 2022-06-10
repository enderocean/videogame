extends SoftBody
class_name NewFishingNet

signal net_cut()
signal net_removed()

export(float, 0.0, 10.0) var time_freeze: float = 1.0
export var floating: bool = false
export var net_cut_scene: PackedScene

export var to_cut_indices: Array = [
	[883, 899],
]

var mesh_data_tool: MeshDataTool = MeshDataTool.new()
var removed: bool = false
var cut_count: int = 0
var cut_areas: int = 0


func net_removed() -> void:
	if floating:
		# TODO: Move upwards
		pass
	else:
		physics_enabled = true
	
	removed = true
	emit_signal("net_removed")


func cut(area: Area) -> void:
	if removed:
		return
	
	# Remove the cut area
	area.queue_free()
	
	# Update the cut count of the
	cut_count += 1
	emit_signal("net_cut", cut_count)
	
	var remaining: int = cut_areas - cut_count
	# No more cut to 
	if remaining <= 0:
		net_removed()


func _ready() -> void:
	set_physics_process(false)
	add_to_group("objectives_nodes")
	
	if not mesh:
		return
	
	# Freeze net after the given time
	yield(get_tree().create_timer(time_freeze), "timeout")
	physics_enabled = false

	# Read the net mesh
	mesh_data_tool.create_from_surface(mesh, 0)
	
	# Create cut parts of the net
	for indices in to_cut_indices:
		# Create the cut node
		var net_cut: Area = net_cut_scene.instance()
		
		# Get global position of each vertex
		var positions: PoolVector3Array = [
			global_transform * mesh_data_tool.get_vertex(indices[0]),
			global_transform * mesh_data_tool.get_vertex(indices[1])
		]
		# Get the middle position between the vertices
		var mid_position: Vector3 = positions[0].linear_interpolate(positions[1], 0.5)
		
		# Set size of the cut mesh to the correspoding length
		var mesh_instance: MeshInstance = net_cut.get_node("MeshInstance")
		var collision_shape: CollisionShape = net_cut.get_node("CollisionShape")
		var mesh: CapsuleMesh = mesh_instance.mesh
		var shape: CapsuleShape = collision_shape.shape
		var distance: float = positions[0].distance_to(positions[1])
		mesh.mid_height = distance
		shape.height = distance / 2
		
		net_cut.look_at_from_position(mid_position, positions[0], Vector3.UP)
		add_child(net_cut)
		
		cut_areas += 1
