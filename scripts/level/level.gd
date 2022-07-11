extends Node
class_name Level

export(String, FILE, "*.tres") var level_data_path: String
var level_data: LevelData

export var depth_max: float = 100.0
export var fog_depth_min: float = 5.0
export var update_environment: bool = true

# Default Environments
var surface_ambient: Dictionary
var underwater_color: Color

var surface_env: Environment = load("res://assets/defaultEnvironment.tres")
var underwater_env: Environment = load("res://assets/underwaterEnvironment.tres")
var underwater_env_original: Environment
var underwater_mesh_scene: PackedScene = load("res://scenes/components/underwater_mesh.tscn")
var underwater_meshes: Array

# core elements of the scene
export var water_path: NodePath = "water"
onready var water: MeshInstance = get_node(water_path)
onready var underwater: MeshInstance = get_node(water_path).get_child(0)

export var sun_path: NodePath = "sun"
onready var sun: Light = get_node_or_null(sun_path)

var vehicle: Vehicle

export var objectives_target: Dictionary = {
	"gripper": 0,
	"vacuum": 0,
	"cutter": 0,
	"grappling_hook": 0,
	"magnet": 0,
	"animal": 0
}

#var objectives: Dictionary = {}
#var objectives_progress: Dictionary = {}
var penalties: Array = []
var score: int = 0
#var destinations: Array
#var destinations_next_index: int = 0

# darkest it gets
onready var cameras = get_tree().get_nodes_in_group("cameras")
onready var surface_altitude: float = water.global_transform.origin.y

var fancy_water
var fancy_underwater
const simple_water = preload("res://assets/maujoe.basic_water_material/materials/basic_water_material.material")

onready var depth: float = 0
onready var last_depth: float = 0

var finished: bool = false

#signal objectives_changed()
signal finished()
signal collectible_obtained(id)
signal penality_added()
signal vehicle_collided()


func _ready() -> void:
	level_data = load(level_data_path)
	
	for node in get_children():
		# Replace the default underwater environment by the one in the scene
		if node is WorldEnvironment:
			if not node.environment:
				continue
			underwater_env = node.environment
		# Assign vehicle node automatically
		if node is Vehicle:
			vehicle = node
		# warning-ignore:return_value_discarded
			vehicle.vehicle_body.connect("body_entered", self, "_on_vehicle_body_entered")
	
	# Save the original environment values before changing it
	underwater_env_original = underwater_env.duplicate()
	
	# Add the underwater meshes for each camera
	for i in range(cameras.size()):
		var camera: Camera = cameras[i]
		if not camera:
			continue
		
		# Disable any cull mask reserved for the meshes
		for j in range(cameras.size()):
			camera.set_cull_mask_bit(10 + j, false)
		
		var underwater_mesh: UnderwaterMesh = underwater_mesh_scene.instance()
		add_child(underwater_mesh)
		underwater_meshes.append(underwater_mesh)
		underwater_mesh.target = camera.get_path()
		
		# Set the same cull mask on the mesh and the camera
		camera.set_cull_mask_bit(10 + i, true)
		underwater_mesh.set_layer_mask_bit(10 + i, true)
	
	# Get base surface values
	surface_ambient = {
		"color": underwater_env.fog_color,
		"depth_end": underwater_env.fog_depth_end
	}
	
	set_physics_process(true)
	update_fog()
	underwater_env.fog_enabled = true
	
# warning-ignore:return_value_discarded
	Globals.connect("fancy_water_changed", self, "_on_fancy_water_changed")

#	# Add all objectives
#	for type in Globals.ObjectiveType.values():
#		var type_name: String = Globals.ObjectiveType.keys()[type].to_lower()
#		if not objectives_target.has(type_name):
#			continue
#		if not objectives_target.get(type_name):
#			continue
#		objectives[type] = objectives_target.get(type_name)
#
#	# Connect to all objectives nodes
#	for node in get_tree().get_nodes_in_group("objectives_nodes"):
#		var objective_tag: ObjectiveTag = ObjectivesManager.get_objective_tag(node)
#		if level_data and level_data.gripper_objectives_count == 0:
#			pass
#
#		if node is DeliveryArea:
#		# warning-ignore:return_value_discarded
#			node.connect("objects_changed", self, "_on_objects_changed")
#		if node is DeliveryTool:
#			node.surface_altitude = surface_altitude
#		# warning-ignore:return_value_discarded
#			node.connect("delivered", self, "_on_tool_delivered")
#		if node is TrapAnimal:
#		# warning-ignore:return_value_discarded
#			node.connect("animal_free", self, "_on_animal_free")
#		if node is NewFishingNet or node is FishingNet:
#		# warning-ignore:return_value_discarded
#			node.connect("net_cut", self, "_on_net_cut")
#		if node is DestinationTriggerArea:
#		# warning-ignore:return_value_discarded
#			node.connect("arrived", self, "_on_destination_arrived")
#			destinations.append(node)
	
#	# Add the destinations as objectives
#	if destinations.size() > 0:
#		objectives[Globals.ObjectiveType.DESTINATION] = destinations.size()
	
	# Connect to all objective areas
#	for node in get_tree().get_nodes_in_group("collectible_tags"):
#		if node is CollectibleTag:
#			node.connect("obtained", self, "_on_collectible_obtained")
#
#	for node in get_tree().get_nodes_in_group("ropes"):
#		if node is Rope:
#			SceneLoader.wait_before_new_scene = true
#			node.connect("created", self, "_on_rope_created", [node])
#			node.initialize()


var ropes: Array
func _on_rope_created(rope: Rope) -> void:
	print("Created ", rope.name, " with ", rope.sections.size(), " sections.")
	ropes.append(rope)
	if ropes.size() == get_tree().get_nodes_in_group("ropes").size():
		SceneLoader.wait_before_new_scene = false


func calculate_buoyancy():
	var buoyants = get_tree().get_nodes_in_group("buoyant")
	for rigidbody in buoyants:
		if not rigidbody is RigidBody:
			push_warning("Component %s does not inherit RigidBody." % rigidbody.name)
			continue

		var buoys = rigidbody.find_node("buoys")
		if buoys:
			var children = buoys.get_children()
			for buoy in children:
				var buoyancy = (
					vehicle.buoyancy
					* (surface_altitude - buoy.global_transform.origin.y)
					/ children.size()
				)

				if buoy.global_transform.origin.y > surface_altitude:
					buoyancy = 0

				vehicle.add_force_local_pos(Vector3.UP * buoyancy, buoy.transform.origin)
		else:
			var buoyancy: float = rigidbody.buoyancy
			if rigidbody.global_transform.origin.y > surface_altitude:
				buoyancy = 0

			rigidbody.add_force(Vector3.UP * buoyancy, rigidbody.transform.basis.y * 0.07)


func calculate_ballasts() -> void:
	var ballasts = vehicle.find_node("ballasts")
	if ballasts:
		var children = ballasts.get_children()
		for ballast in children:
			vehicle.add_force_local_pos(
				Vector3(0, -vehicle.ballast_kg * 9.8, 0), ballast.transform.origin
			)


func update_fog():
	var vehicles = get_tree().get_nodes_in_group("vehicles")
	for vehicle in vehicles:
		if not vehicle is RigidBody:
			push_warning("Component %s does not inherit RigidBody." % vehicle.name)
			continue
		
		var rov_camera = get_node(str(vehicle.get_path()) + "/Camera")
		depth = rov_camera.global_transform.origin.y - surface_altitude
		last_depth = depth
		var normalized_depth: float = clamp(1.0 - ((depth_max - abs(depth)) / depth_max), 0.0, 1.0)
		var new_color: Color = underwater_env_original.fog_color.darkened(normalized_depth)

		underwater_env.fog_depth_end = max(fog_depth_min, underwater_env_original.fog_depth_end - (normalized_depth * underwater_env_original.fog_depth_end))
		underwater_env.background_color = new_color
		
		if underwater_env.background_sky:
			underwater_env.background_sky.sky_horizon_color = new_color
			underwater_env.background_sky.ground_bottom_color = new_color
			underwater_env.background_sky.ground_horizon_color = new_color
			underwater_env.background_sky.sky_energy = max(5.0 - 5 * normalized_depth, 0.0)
		
		if underwater_env.fog_enabled:
			underwater_env.fog_color = new_color
		
		if sun:
			sun.light_energy = max(0, 0.3 - 0.5 * normalized_depth)

		underwater_env.ambient_light_energy = 1.0 - normalized_depth
		underwater_env.ambient_light_color = new_color
		
		# Underwater effects
		for camera in cameras:
			depth = camera.global_transform.origin.y - surface_altitude
			camera.environment = surface_env if depth > 0 else underwater_env
			if depth > 0:
				camera.set_cull_mask_bit(3, false)
			else:
				camera.set_cull_mask_bit(3, true)


func _process(_delta: float) -> void:
	if not update_environment:
		return
	
	update_fog()


func _physics_process(_delta: float) -> void:
	calculate_buoyancy()
	calculate_ballasts()
	
	for underwater_mesh in underwater_meshes:
		if not underwater_mesh._target:
			continue
		underwater_mesh.visible = underwater_mesh._target.global_transform.origin.y < surface_altitude


func _on_fancy_water_changed() -> void:
	if Globals.fancy_water:
		water.set_surface_material(0, fancy_water)
		underwater.set_surface_material(0, fancy_underwater)
	else:
		# save previous materials
		fancy_underwater = underwater.get_surface_material(0)
		fancy_water = water.get_surface_material(0)
		water.set_surface_material(0, simple_water)
		underwater.set_surface_material(0, simple_water)


#func _on_objects_changed(area, objects: Array) -> void:
#	if finished or not area:
#		return
#
#	match area.objective_type:
#		Globals.ObjectiveType.GRIPPER:
#			objectives_progress[Globals.ObjectiveType.GRIPPER] = objects.size()
#			print("Delivered: ", objectives_progress.get(Globals.ObjectiveType.GRIPPER), " / ", objectives.get(Globals.ObjectiveType.GRIPPER))
#
#		Globals.ObjectiveType.VACUUM:
#			objectives_progress[Globals.ObjectiveType.VACUUM] = objects.size()
#			print("Vacuumed: ", objectives_progress.get(Globals.ObjectiveType.VACUUM), " / ", objectives.get(Globals.ObjectiveType.VACUUM))
#
#	check_objectives()
#	emit_signal("objectives_changed")


#func _on_tool_delivered(objective_type) -> void:
#	if objectives_progress.has(objective_type):
#		objectives_progress[objective_type] += 1
#	else:
#		objectives_progress[objective_type] = 1
#
#	print("Tool delivered: ", objectives_progress.get(objective_type), " / ", objectives.get(objective_type))
#
#	check_objectives()
#	emit_signal("objectives_changed")


func _on_net_cut(nb_cut: int) -> void:
	if objectives_progress.has(Globals.ObjectiveType.CUTTER):
		objectives_progress[Globals.ObjectiveType.CUTTER] += 1
	else:
		objectives_progress[Globals.ObjectiveType.CUTTER] = 1
	
	print("Cutted: ", objectives_progress.get(Globals.ObjectiveType.CUTTER), " / ", objectives.get(Globals.ObjectiveType.CUTTER))
	
	check_objectives()
	emit_signal("objectives_changed")


func _on_animal_free(animal: TrapAnimal) -> void:
	if objectives_progress.has(Globals.ObjectiveType.ANIMAL):
		objectives_progress[Globals.ObjectiveType.ANIMAL] += 1
	else:
		objectives_progress[Globals.ObjectiveType.ANIMAL] = 1

	print("Animaled: ", objectives_progress.get(Globals.ObjectiveType.ANIMAL), " / ", objectives.get(Globals.ObjectiveType.ANIMAL))
	
	check_objectives()
	emit_signal("objectives_changed")


func _on_collectible_obtained(id: String) -> void:
	emit_signal("collectible_obtained", id)


func _on_destination_arrived(node: DestinationTriggerArea) -> void:
	var index: int = destinations.find(node)
	if index == -1:
		printerr(node.name, " not found in current scene destinations.")
		return
	
	if not objectives_progress.has(Globals.ObjectiveType.DESTINATION):
		objectives_progress[Globals.ObjectiveType.DESTINATION] = 0
	
	if index != objectives_progress[Globals.ObjectiveType.DESTINATION]:
		return
	
	objectives_progress[Globals.ObjectiveType.DESTINATION] += 1
	
	print("Arrived: ", objectives_progress.get(Globals.ObjectiveType.DESTINATION), " / ", destinations.size())
	
	if objectives_progress.get(Globals.ObjectiveType.DESTINATION) < destinations.size():
		destinations_next_index = objectives_progress.get(Globals.ObjectiveType.DESTINATION)
	
	check_objectives()
	emit_signal("objectives_changed")


func _on_vehicle_body_entered(body: Node) -> void:
	var collision_tag: PenaltyCollisionTag = null
	var reason: String
	for child in body.get_children():
		if child is PenaltyCollisionTag:
			collision_tag = child
			break
	
	if not collision_tag:
		return
	
	vehicle.vehicle_body.sounds.play("collision")
	emit_signal("vehicle_collided")
	add_penalty("Collided with %s" % body.name, collision_tag.points)


func check_objectives() -> void:
	# First check if all the objectives are in the progress dictionary
	if objectives.keys().size() != objectives_progress.keys().size():
		return
	
	finished = true
	for objective in objectives.keys():
		if not objectives.has(objective):
			continue
		
		# Don't already have this objective in progress or done
		if not objectives_progress.has(objective):
			continue
		
		# Objective in progress
		if objectives_progress.get(objective) < objectives.get(objective):
			finished = false

	if finished:
		emit_signal("finished")


# Add a penalty with a reason which could be used
func add_penalty(reason: String, points: int) -> void:
	var penalty: Dictionary = {
		"reason": reason,
		"points": points
	}
	penalties.append(penalty)
	print("Added penalty: ", penalty.reason, ", removed ", penalty.points, " points.")
	emit_signal("penality_added")


func get_vehicle_orientation() -> float:
	return vehicle.vehicle_body.rotation_degrees.y


func get_vehicle_depth() -> float:
	return vehicle.vehicle_body.global_transform.origin.y - surface_altitude


func get_vehicle_speed() -> int:
	return vehicle.vehicle_body.speed_index
