extends Node

# This code is temporary, waiting for the localization integration
static func get_objective_text(objectiveType) -> String:
	match objectiveType:
		Level.ObjectiveType.GRIPPER:
			return "Deliver objects with the Gripper"
		Level.ObjectiveType.VACUUM:
			return "Collect objects with the Vacuum"
		Level.ObjectiveType.CUTTER:
			return "Cut off nets with the Cutter"
		Level.ObjectiveType.GRAPPLING_HOOK:
			return "Collected with the Grappling hook"
	return ""
