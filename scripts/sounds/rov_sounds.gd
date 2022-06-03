extends "res://scripts/sounds/sounds.gd"
class_name ROVSounds


func get_sounds() -> Dictionary:
	return {
		"move_forward":
		[
			"res://assets/sounds/ROV_Move_Forward_Slow_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Forward_Slow_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Forward_Slow_Loop_03.wav",
		],
		"move_backward":
		[
			"res://assets/sounds/ROV_Move_Backward_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Backward_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Backward_Loop_03.wav",
		],
		"move_left":
		[
			"res://assets/sounds/ROV_Move_Left_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Left_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Left_Loop_03.wav",
		],
		"move_right":
		[
			"res://assets/sounds/ROV_Move_Right_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Right_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Right_Loop_03.wav",
		],
		"move_up":
		[
			"res://assets/sounds/ROV_Move_Up_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Up_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Up_Loop_03.wav",
		],
		"move_down":
		[
			"res://assets/sounds/ROV_Move_Down_Loop_01.wav",
			"res://assets/sounds/ROV_Move_Down_Loop_02.wav",
			"res://assets/sounds/ROV_Move_Down_Loop_03.wav",
		],
		"camera_up": "res://assets/sounds/Rov_Camera_Up_01.wav",
		"camera_down": "res://assets/sounds/Rov_Camera_Down_01.wav",
		"camera_max": "res://assets/sounds/Rov_Camera_Max_01.wav",
		"gripper_open":
		[
			"res://assets/sounds/ROV_Gripper_Open_01.wav",
		],
		"gripper_close":
		[
			"res://assets/sounds/ROV_Gripper_Close_01.wav",
		],
		"claw_open":
		[
			"res://assets/sounds/Rov_Claw_Open_01.wav",
		],
		"claw_close":
		[
			"res://assets/sounds/Rov_Claw_Close_01.wav",
		],
		"collision":
		[
			"res://assets/sounds/collision_penalty_01.wav",
			"res://assets/sounds/collision_penalty_02.wav",
			"res://assets/sounds/collision_penalty_03.wav",
		]
	}
