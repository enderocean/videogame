extends Node
class_name Level

const BUOYANCY: float = 10.0  # newtons?
const HEIGHT: float = 2.4  # TODO: get this programatically

# Default Environments
var surface_env: Environment = load("res://assets/defaultEnvironment.tres")
var underwater_env: Environment = load("res://assets/underwaterEnvironment.tres")

## Used to override the default underwater environment
## Must be a Environment resource
export var underwater_env_override: Resource

# core elements of the scene
export var water_path: NodePath = "water"
onready var water: MeshInstance = get_node(water_path)
onready var underwater: MeshInstance = get_node(water_path).get_child(0)

export var sun_path: NodePath = "sun"
onready var sun: Light = get_node(sun_path)

export var vehicle_path: NodePath
onready var vehicle: Vehicle = get_node(vehicle_path)

enum ObjectiveType {
	GRIPPER,
	VACUUM,
	CUTTER,
	GRAPPLING_HOOK,
	MAGNET,
}

export var objectives_target: Dictionary = {
	"gripper": 0,
	"vacuum": 0,
	"cutter": 0,
	"grappling_hook": 0,
	"magnet": 0,
}
var objectives: Dictionary = {}

var objectives_progress: Dictionary = {}
var score: int = 0

# darkest it gets
onready var cameras = get_tree().get_nodes_in_group("cameras")
onready var surface_altitude: float = water.global_transform.origin.y

var fancy_water
var fancy_underwater
const simple_water = preload("res://assets/maujoe.basic_water_material/materials/basic_water_material.material")

onready var depth: float = 0
onready var last_depth: float = 0

var finished: bool = false
signal finished(score)


func _ready():
	# Replace the default underwater environment
	if underwater_env_override and underwater_env_override is Environment:
		underwater_env = underwater_env_override

	set_physics_process(true)
	update_fog()
	underwater_env.fog_enabled = true

	Globals.connect("fancy_water_changed", self, "_on_fancy_water_changed")

	# Add all objectives
	for type in ObjectiveType.values():
		var type_name: String = ObjectiveType.keys()[type].to_lower()
		if not objectives_target.has(type_name):
			continue
		if not objectives_target.get(type_name):
			continue
		objectives[type] = objectives_target.get(type_name)
#		var group: String = "objective_%s" % str(type).to_lower()
#		var objective_objects: Array = get_tree().get_nodes_in_group(group)

#		if objective_objects.size() > 0:
#			objectives[type] = objective_objects.size()
	
	
	for node in get_tree().get_nodes_in_group("objectives_nodes"):
		node.connect("objects_changed", self, "_on_objects_changed")


func calculate_buoyancy_and_ballast():
	var vehicles = get_tree().get_nodes_in_group("buoyant")
	for vehicle in vehicles:
		if not vehicle is RigidBody:
			push_warning("Component %s does not inherit RigidBody." % vehicle.name)
			continue

		var buoys = vehicle.find_node("buoys")
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
			var buoyancy: float = vehicle.buoyancy
			if vehicle.global_transform.origin.y > surface_altitude:
				buoyancy = 0

			vehicle.add_force(Vector3.UP * buoyancy, vehicle.transform.basis.y * 0.07)

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

		var fog_distance = max(50 + 1 * depth, 20)
		underwater_env.fog_depth_end = fog_distance
		var deep_factor = min(max(-depth / 50, 0), 1.0)
		Globals.deep_factor = deep_factor
		var new_color = Globals.surface_ambient.linear_interpolate(
			Globals.deep_ambient, deep_factor
		)
		Globals.current_ambient = new_color.darkened(0.5)
		underwater_env.background_color = new_color
		underwater_env.background_sky.sky_horizon_color = new_color
		underwater_env.background_sky.ground_bottom_color = new_color
		underwater_env.background_sky.ground_horizon_color = new_color
		underwater_env.fog_color = new_color
		underwater_env.ambient_light_energy = 1.0 - deep_factor
		underwater_env.ambient_light_color = new_color  #surface_ambient.linear_interpolate(deep_ambient, max(1 - depth/50, 0))
		sun.light_energy = max(0.3 - 0.5 * deep_factor, 0)
		underwater_env.background_sky.sky_energy = max(5.0 - 5 * deep_factor, 0.0)

		for camera in cameras:
			depth = camera.global_transform.origin.y - surface_altitude
			camera.environment = surface_env if depth > 0 else underwater_env
			if depth > 0:
				camera.cull_mask = 3
			else:
				camera.cull_mask = 5


func _process(_delta: float) -> void:
	update_fog()


func _physics_process(_delta: float) -> void:
	calculate_buoyancy_and_ballast()


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


func _on_objects_changed(area, objects: Array) -> void:
	if finished or not area:
		return
	
	if area.objective_type == ObjectiveType.GRIPPER:
		objectives_progress[ObjectiveType.GRIPPER] = objects.size()
		score = objectives_progress[ObjectiveType.GRIPPER]
		print("Delivered: ", objectives_progress.get(ObjectiveType.GRIPPER), " / ", objectives.get(ObjectiveType.GRIPPER))

	if area.objective_type == ObjectiveType.VACUUM:
		objectives_progress[ObjectiveType.VACUUM] = objects.size()
		score = objectives_progress[ObjectiveType.VACUUM]
		print("Vacuumed: ", objectives_progress.get(ObjectiveType.VACUUM), " / ", objectives.get(ObjectiveType.VACUUM))
	
	check_objectives()

func check_objectives() -> void:
	finished = true
	for objective in objectives.keys():
		if not objectives.has(objective):
			continue
		
		if not objectives_progress.has(objective):
			continue
		
		if objectives_progress.get(objective) < objectives.get(objective):
			finished = false
	
	if finished:
		emit_signal("finished", score)
