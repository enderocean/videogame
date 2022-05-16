extends Node

# This code is temporary, waiting for the localization integration
static func get_objective_text(objectiveType) -> String:
	match objectiveType:
		Globals.ObjectiveType.GRIPPER:
			return "Deliver objects with the Gripper"
		Globals.ObjectiveType.VACUUM:
			return "Collect objects with the Vacuum"
		Globals.ObjectiveType.CUTTER:
			return "Cut off nets with the Cutter"
		Globals.ObjectiveType.GRAPPLING_HOOK:
			return "Collected with the Grappling hook"
		Globals.ObjectiveType.ANIMAL:
			return "Freed animals"
	return ""
