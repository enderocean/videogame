extends Node

static func get_vehicle_tool_text(vehicle_tool) -> String:
	if vehicle_tool is GripperTool:
		return "TOOL_GRIPPER"
	elif vehicle_tool is VacuumTool:
		return "TOOL_VACUUM"
	elif vehicle_tool is CutterTool:
		return "TOOL_CUTTER"
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
		"speed_up": "Speed Up",
		"speed_down": "Speed Down",
		"tool_open": "Open Tool",
		"tool_close": "Close Tool",
		"tool_switch": "Switch Tool",
		"lights_up": "Lights Up",
		"lights_down": "Lights Down",
		"camera_up": "Camera Up",
		"camera_down": "Camera Down",
		"camera_switch": "Switch Camera",
		"camera_external_toggle": "Toggle External Camera"
	}
	
	if inputs.has(input_action):
		return inputs.get(input_action)
	return ""


# This code is temporary, waiting for the localization integration
static func get_setting_text(setting_key: String) -> String:
	var settings: Dictionary = {
		"fullscreen": "Fullscreen",
		"vsync": "Enable VSync",
		"fancy_water": "Fancy Water",
		"physics_rate": "Physics Rate",
		"volume_master": "Master",
		"volume_effects": "Effects",
		"volume_radio": "Radio",
		"volume_music": "Music"
	}
	
	if settings.has(setting_key):
		return settings.get(setting_key)
	return ""
