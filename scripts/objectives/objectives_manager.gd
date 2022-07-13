extends Node

var objectives: Dictionary = {}
var objectives_progress: Dictionary = {}
var destinations: Array
var destinations_next_index: int = 0
var finished: bool = false
var level_data: LevelData

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
		var objective_progress = objectives_progress.get(objective)
		if objective_progress is Array:
			if objective_progress.size() < objectives.get(objective).size():
				finished = false
		else:
			if objective_progress < objectives.get(objective):
				finished = false

	if finished:
		emit_signal("finished")


# Add to the objectives target the given node
func add_objective_target_from(node: Node) -> void:
	if not node:
		return
	
	if node is DeliveryObject:
		match node.objective_type:
			Globals.ObjectiveType.GRIPPER:
				add_objective_target(Globals.ObjectiveType.GRIPPER, 1)
			Globals.ObjectiveType.VACUUM:
				add_objective_target(Globals.ObjectiveType.VACUUM, 1)
			Globals.ObjectiveType.MAGNET:
				add_objective_target(Globals.ObjectiveType.MAGNET, 1)
			Globals.ObjectiveType.GRAPPLING_HOOK:
				add_objective_target(Globals.ObjectiveType.GRAPPLING_HOOK, 1)
			Globals.ObjectiveType.FIND:
				add_objective_target(Globals.ObjectiveType.FIND, 1)
	
	elif node is GrapplingHookDeliveryTool:
		add_objective_target(Globals.ObjectiveType.GRAPPLING_HOOK, 1)
	elif node is MagnetDeliveryTool:
		add_objective_target(Globals.ObjectiveType.MAGNET, 1)
	elif node is TrapAnimal:
		add_objective_target(Globals.ObjectiveType.ANIMAL, 1)
	elif node is NewFishingNet:
		add_objective_target(Globals.ObjectiveType.CUTTER, node.cut_areas)
	elif node is DestinationTriggerArea:
		add_objective_target(Globals.ObjectiveType.DESTINATION, 1)
	elif node is InputObjective:
		add_objective_target(Globals.ObjectiveType.INPUT, 1)


# Used to quickly add a new objective
func add_objective_target(objective_type, count: int = 1) -> void:
	if not objectives.has(objective_type):
		objectives[objective_type] = 0
		
	objectives[objective_type] += count


# Used to quickly add a new objective node
func add_objective_target_node(objective_type, node: Node) -> void:
	if not objectives.has(objective_type):
		objectives[objective_type] = []
		
	objectives[objective_type].append(node)


# Used to quickly add progression for an objective
func set_objective_progress(objective_type, count: int = 1, additive: bool = true) -> void:
	# Check if the objective type is present
	if not objectives_progress.has(objective_type):
		objectives_progress[objective_type] = 0
	
	# if we want to add the value
	if additive:
		objectives_progress[objective_type] += count
	else:
		objectives_progress[objective_type] = count
	
	check_objectives()
	emit_signal("objectives_changed")


func has_objective_tag(node: Node) -> bool:
	for child in node.get_children():
		if child is ObjectiveTag:
			return true
	return false


func initialize(level_data: LevelData) -> void:
	objectives.clear()
	objectives_progress.clear()
	destinations.clear()
	destinations_next_index = 0
	finished = false

	if level_data:
		if level_data.gripper_objectives_count > 0:
			objectives[Globals.ObjectiveType.GRIPPER] = level_data.gripper_objectives_count
		if level_data.vacuum_objectives_count > 0:
			objectives[Globals.ObjectiveType.VACUUM] = level_data.vacuum_objectives_count
		if level_data.cutter_objectives_count > 0:
			objectives[Globals.ObjectiveType.CUTTER] = level_data.cutter_objectives_count

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
			add_objective_target_from(node)
		if node is DestinationTriggerArea:
		# warning-ignore:return_value_discarded
			node.connect("arrived", self, "_on_destination_arrived")
			destinations.append(node)
		if node is InputObjective:
		# warning-ignore:return_value_discarded
			node.connect("completed", self, "_on_input_objective_completed", [node])

	
	# Add the destinations as objectives
	if destinations.size() > 0:
		add_objective_target(Globals.ObjectiveType.DESTINATION, destinations.size())
	
	# Check for ObjectiveTags in the scene
	for node in get_tree().get_nodes_in_group("objective_tags"):
		if node is ObjectiveTag:
			var parent = node.get_parent()
			if parent is DeliveryObject:
				# Check if a fixed number is set for the following objectives, ignore it if set
				match parent.objective_type:
					Globals.ObjectiveType.GRIPPER:
						if level_data.gripper_objectives_count > 0:
							continue
					Globals.ObjectiveType.VACUUM:
						if level_data.vacuum_objectives_count > 0:
							continue
					Globals.ObjectiveType.CUTTER:
						if level_data.cutter_objectives_count > 0:
							continue
			
			# Add to the target objectives
			add_objective_target_from(node.get_parent())


func get_objective_text(objective_type) -> String:
	match objective_type:
		Globals.ObjectiveType.GRIPPER:
			return tr("OBJECTIVE_GRIPPER_TEXT")
		Globals.ObjectiveType.VACUUM:
			return tr("OBJECTIVE_VACUUM_TEXT")
		Globals.ObjectiveType.CUTTER:
			return tr("OBJECTIVE_CUTTER_TEXT")
		Globals.ObjectiveType.MAGNET:
			return tr("OBJECTIVE_MAGNET_TEXT")
		Globals.ObjectiveType.GRAPPLING_HOOK:
			return tr("OBJECTIVE_GRAPPLING_HOOK_TEXT")
		Globals.ObjectiveType.ANIMAL:
			return tr("OBJECTIVE_ANIMAL_TEXT")
		Globals.ObjectiveType.DESTINATION:
			return tr("OBJECTIVE_DESTINATION_TEXT")
		Globals.ObjectiveType.FIND:
			return tr("OBJECTIVE_FIND_TEXT")
		Globals.ObjectiveType.INPUT:
			return tr("OBJECTIVE_INPUT_TEXT")
	return ""


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	SceneLoader.connect("scene_loaded", self, "_on_scene_loaded")


func _on_scene_loaded(scene_data: Dictionary) -> void:
	level_data = scene_data.level_data
	if level_data:
		initialize(level_data)


func _on_objects_changed(area, objects: Array) -> void:
	if finished or not area:
		return
	
	match area.objective_type:
		Globals.ObjectiveType.GRIPPER:
			set_objective_progress(Globals.ObjectiveType.GRIPPER, objects.size(), false)
			print("Delivered: ", objectives_progress.get(Globals.ObjectiveType.GRIPPER), " / ", objectives.get(Globals.ObjectiveType.GRIPPER))

		Globals.ObjectiveType.VACUUM:
			set_objective_progress(Globals.ObjectiveType.VACUUM, objects.size(), false)
			print("Vacuumed: ", objectives_progress.get(Globals.ObjectiveType.VACUUM), " / ", objectives.get(Globals.ObjectiveType.VACUUM))
			
		Globals.ObjectiveType.FIND:
			set_objective_progress(Globals.ObjectiveType.FIND, objects.size(), false)
			print("Found: ", objectives_progress.get(Globals.ObjectiveType.FIND), " / ", objectives.get(Globals.ObjectiveType.FIND))


func _on_tool_delivered(objective_type) -> void:
	set_objective_progress(objective_type, 1, true)
	print("Tool delivered: ", objectives_progress.get(objective_type), " / ", objectives.get(Globals.objective_type))


func _on_net_cut(nb_cut: int) -> void:
	set_objective_progress(Globals.ObjectiveType.CUTTER, 1, true)
	print("Cutted: ", objectives_progress.get(Globals.ObjectiveType.CUTTER), " / ", objectives.get(Globals.ObjectiveType.CUTTER))


func _on_animal_free(animal: TrapAnimal) -> void:
	set_objective_progress(Globals.ObjectiveType.ANIMAL, 1, true)
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


func _on_input_objective_completed(input_objective: InputObjective) -> void:
	print(input_objective.action_name, " completed")
