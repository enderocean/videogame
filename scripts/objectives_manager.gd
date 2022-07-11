extends Node
class_name ObjectivesManager

enum ObjectiveType {
	GRIPPER,
	VACUUM,
	CUTTER,
	GRAPPLING_HOOK,
	MAGNET,
	ANIMAL,
	DESTINATION
}

enum DeliveryToolType {
	GRAPPLING_HOOK,
	MAGNET,
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


func _ready() -> void:
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
		objectives[Globals.ObjectiveType.DESTINATION] = destinations.size()
	
	for node in get_tree().get_nodes_in_group("objective_tags"):
		if node is ObjectiveTag:
			node.connect("obtained", self, "_on_collectible_obtained")
	
	for node in get_tree().get_nodes_in_group("collectible_tags"):
		if node is CollectibleTag:
			node.connect("obtained", self, "_on_collectible_obtained")
	
	for node in get_tree().get_nodes_in_group("ropes"):
		if node is Rope:
			SceneLoader.wait_before_new_scene = true
			node.connect("created", self, "_on_rope_created", [node])
			node.initialize()


func _on_objects_changed(area, objects: Array) -> void:
	if finished or not area:
		return
	
	match area.objective_type:
		Globals.ObjectiveType.GRIPPER:
			objectives_progress[Globals.ObjectiveType.GRIPPER] = objects.size()
			print("Delivered: ", objectives_progress.get(Globals.ObjectiveType.GRIPPER), " / ", objectives.get(Globals.ObjectiveType.GRIPPER))

		Globals.ObjectiveType.VACUUM:
			objectives_progress[Globals.ObjectiveType.VACUUM] = objects.size()
			print("Vacuumed: ", objectives_progress.get(Globals.ObjectiveType.VACUUM), " / ", objectives.get(Globals.ObjectiveType.VACUUM))
	
	check_objectives()
	emit_signal("objectives_changed")


func _on_tool_delivered(objective_type) -> void:
	if objectives_progress.has(objective_type):
		objectives_progress[objective_type] += 1
	else:
		objectives_progress[objective_type] = 1
	
	print("Tool delivered: ", objectives_progress.get(objective_type), " / ", objectives.get(objective_type))
	
	check_objectives()
	emit_signal("objectives_changed")


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
