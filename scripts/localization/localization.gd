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

# This code is temporary, waiting for the localization integration
static func get_vehicle_tool_text(vehicle_tool) -> String:
	if vehicle_tool is GripperTool:
		return "Gripper"
	elif vehicle_tool is VacuumTool:
		return "Vacuum"
	elif vehicle_tool is CutterTool:
		return "Cutter"
	return ""


# This code is temporary, waiting for the localization integration
static func get_input_action_text(input_action: String) -> String:
	var inputs: Dictionary = {
		"forward": "Forward",
		"backwards": "Backwards",
		"upwards": "Upwards",
		"downwards": "Downwards",
		"strafe_left": "Strafe Left",
		"strafe_right": "Strafe Right",
		"rotate_left": "Rotate Left",
		"rotate_right": "Rotate Right",
		"tool_open": "Open Tool",
		"tool_close": "Close Tool",
		"tool_switch": "Switch Tool",
		"camera_switch": "Switch Camera"
	}
	
	if inputs.has(input_action):
		return inputs.get(input_action)
	return ""


# This code is temporary, waiting for the localization integration
static func get_setting_text(setting_key: String) -> String:
	var settings: Dictionary = {
		"fullscreen": "Fullscreen",
		"vsync": "Enable VSync",
		"volume_master": "Master",
		"volume_effects": "Effects",
		"volume_radio": "Radio",
		"volume_music": "Music"
	}
	
	if settings.has(setting_key):
		return settings.get(setting_key)
	return ""
