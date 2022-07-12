extends Node

enum ObjectiveType {
	GRIPPER,
	VACUUM,
	CUTTER,
	GRAPPLING_HOOK,
	MAGNET,
	ANIMAL,
	DESTINATION
}

var objectives: Dictionary = {}
var objectives_progress: Dictionary = {}
var destinations: Array
var destinations_next_index: int = 0
var finished: bool = false

signal objectives_changed()
signal finished()

# Return the first ObjectiveTag in the children of the given node, returns null if they are none  
static func get_objective_tag(node: Node) -> ObjectiveTag:
	for child in node.get_children():
		if child is ObjectiveTag:
			return child
	return null


func check_objectives() -> void:
	# First check if all the objectives are in the progress dictionary
	if objectives.keys().size() != objectives_progress.keys().size():
		return
	
	finished = true
	for objective in objectives.keys():
		# Don't already have this objective in progress or done
		if not objectives_progress.has(objective):
			continue
		
		# Objective in progress
		if objectives_progress.get(objective) < objectives.get(objective):
			finished = false

	if finished:
		emit_signal("finished")


# Add to the objectives target the given node
func add_objective_target_from(node: Node) -> void:
	if node is DeliveryObject:
		match node.objective_type:
			ObjectiveType.GRIPPER:
				add_objective_target(ObjectiveType.GRIPPER, 1)
			ObjectiveType.VACUUM:
				add_objective_target(ObjectiveType.VACUUM, 1)
			ObjectiveType.MAGNET:
				add_objective_target(ObjectiveType.MAGNET, 1)
			ObjectiveType.GRAPPLING_HOOK:
				add_objective_target(ObjectiveType.GRAPPLING_HOOK, 1)
			
	elif node is GrapplingHookDeliveryTool:
		add_objective_target(ObjectiveType.GRAPPLING_HOOK, 1)
	elif node is MagnetDeliveryTool:
		add_objective_target(ObjectiveType.MAGNET, 1)
	elif node is TrapAnimal:
		add_objective_target(ObjectiveType.ANIMAL, 1)
	elif node is NewFishingNet:
		add_objective_target(ObjectiveType.CUTTER, node.cut_areas)
	elif node is DestinationTriggerArea:
		add_objective_target(ObjectiveType.DESTINATION, 1)


# Used to quickly add a new objective
func add_objective_target(objective_type, count: int = 1) -> void:
	if not objectives.has(objective_type):
		objectives[objective_type] = 0
		
	objectives[objective_type] += count


# Used to quickly add progression for an objective
func set_objective_progress(objective_type, count: int = 1, additive: bool = true) -> void:
	# Check if the objective type is present
	if not objectives_progress.has(objective_type):
		objectives_progress[objective_type] = 0
	
	# if we want to set a fix value instead of adding it
	if not additive:
		objectives_progress[objective_type] = count
		return
	
	objectives_progress[objective_type] += count
	
	check_objectives()
	emit_signal("objectives_changed")


func initialize(level_data: LevelData) -> void:
	objectives.clear()
	objectives_progress.clear()
	destinations.clear()
	destinations_next_index = 0
	finished = false

#	# Add all objectives
#	for type in ObjectiveType.values():
#		if objectives.has(type):
#			continue
#
#		objectives[type] = 0

	# Connect to all objectives nodes
	for node in get_tree().get_nodes_in_group("objectives_nodes"):
		if node is DeliveryArea:
		# warning-ignore:return_value_discarded
			node.connect("objects_changed", self, "_on_objects_changed")
		if node is DeliveryTool:
		# warning-ignore:return_value_discarded
			node.connect("delivered", self, "_on_tool_delivered")
		if node is TrapAnimal:
		# warning-ignore:return_value_discarded
			node.connect("animal_free", self, "_on_animal_free")
		if node is NewFishingNet or node is FishingNet:
		# warning-ignore:return_value_discarded
			node.connect("net_cut", self, "_on_net_cut")
		if node is DestinationTriggerArea:
		# warning-ignore:return_value_discarded
			node.connect("arrived", self, "_on_destination_arrived")
			destinations.append(node)
	
	# Add the destinations as objectives
	if destinations.size() > 0:
		add_objective_target(ObjectiveType.DESTINATION, destinations.size())
	
	for node in get_tree().get_nodes_in_group("objective_tags"):
		if node is ObjectiveTag:
			add_objective_target_from(node.get_parent())


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	SceneLoader.connect("scene_loaded", self, "_on_scene_loaded")


func _on_scene_loaded(scene_data: Dictionary) -> void:
	var level_data: LevelData = scene_data.level_data
	if level_data:
		print(level_data.title)
		initialize(level_data)


func _on_objects_changed(area, objects: Array) -> void:
	if finished or not area:
		return
	
	match area.objective_type:
		Globals.ObjectiveType.GRIPPER:
			set_objective_progress(ObjectiveType.GRIPPER, objects.size(), false)
			print("Delivered: ", objectives_progress.get(ObjectiveType.GRIPPER), " / ", objectives.get(ObjectiveType.GRIPPER))

		Globals.ObjectiveType.VACUUM:
			set_objective_progress(ObjectiveType.VACUUM, objects.size(), false)
			print("Vacuumed: ", objectives_progress.get(ObjectiveType.VACUUM), " / ", objectives.get(ObjectiveType.VACUUM))


func _on_tool_delivered(objective_type) -> void:
	set_objective_progress(objective_type, 1, true)
	print("Tool delivered: ", objectives_progress.get(objective_type), " / ", objectives.get(objective_type))


func _on_net_cut(nb_cut: int) -> void:
	set_objective_progress(ObjectiveType.CUTTER, 1, true)
	print("Cutted: ", objectives_progress.get(Globals.ObjectiveType.CUTTER), " / ", objectives.get(Globals.ObjectiveType.CUTTER))


func _on_animal_free(animal: TrapAnimal) -> void:
	set_objective_progress(ObjectiveType.ANIMAL, 1, true)
	print("Animaled: ", objectives_progress.get(Globals.ObjectiveType.ANIMAL), " / ", objectives.get(Globals.ObjectiveType.ANIMAL))


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
