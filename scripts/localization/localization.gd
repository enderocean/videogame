extends Node

# This code is temporary, waiting for the localization integration
static func get_objective_text(objective_type) -> String:
	match objective_type:
		Globals.ObjectiveType.GRIPPER:
			return "Delivered objects with the Gripper"
		Globals.ObjectiveType.VACUUM:
			return "Collected objects with the Vacuum"
		Globals.ObjectiveType.CUTTER:
			return "Cut nets ropes with the Cutter"
		Globals.ObjectiveType.MAGNET:
			return "Collected with the Magnet"
		Globals.ObjectiveType.GRAPPLING_HOOK:
			return "Collected with the Grappling hook"
		Globals.ObjectiveType.ANIMAL:
			return "Freed animals"
	return ""
