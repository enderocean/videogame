extends Control

export var licences_popup_path: NodePath
onready var licences_popup: AcceptDialog = get_node(licences_popup_path)

var downloaded_files = []

class LevelLoader:
	var bin_path = OS.get_executable_path().get_base_dir()

	func ensure_levels_folder_exists():
		var directory = Directory.new();
		directory.open(bin_path)
		directory.make_dir("levels")

	func list_available_external_levels():
		var dir = Directory.new()
		dir.open(bin_path + "/levels")
		print("Looking for additional levels at %s" % bin_path + "/levels")
		dir.list_dir_begin()
		var found = []
	
		# list .pck files
		while true:
			var file = dir.get_next()
			if file.empty():
				break
			elif not file.begins_with(".") and file.ends_with(".pck"):
				found.append(file)
		dir.list_dir_end()
		
		# validate .pck files
		# They must have a custom_level.tscn file
		var valid = {}
		for file in found:
			if not ProjectSettings.load_resource_pack("res://levels/" + file):
				print("Failed to load file: " + file)
			# Now one can use the assets as if they had them in the project from the start
			var imported_scene = load("res://custom_level.tscn")
			if imported_scene == null:
				print("Unable to find 'custom_level.tscn' in file " + file)
				continue
			var level_name = file
			valid[file] = level_name
		return valid

func add_status(text: String):
	print(text)
#	$HBoxContainer/Menu/statusLabel.text += text + "\n"
	
func download_file(url : String, file_name : String):
	add_status("downloading " + file_name)
	var http = HTTPRequest.new()
	add_child(http)
	http.set_download_file(file_name)
	http.request(url)
	http.connect("request_completed", self, "_on_download_finished", [file_name])

func _all_files_downloaded():
	if OS.get_name() == "Windows":
		return len(downloaded_files) == 4
	elif OS.get_name() == "X11":
		return len(downloaded_files) == 1
		
func _on_download_finished(result, response_code, headers, body, file_name):
	add_status("done downloading " + file_name)
	downloaded_files.append(file_name)
	if _all_files_downloaded():
		_start_sitl()

func _start_sitl():
	
	if OS.get_name() == "Windows":
		var binary = File.new()
		binary.open("user://ardusub.exe", File.READ)
		print(binary.get_path_absolute())
		Globals.sitl_pid = OS.execute(binary.get_path_absolute(), ["-S","--model","JSON","--speedup","1","-I0","--home","33.810313,-118.39386700000001,0.0,270.0"], false)
		print(Globals.sitl_pid)
		add_status("SITL is running")
		$HBoxContainer/Menu/Buttons.visible = true
		
	elif OS.get_name() == "X11":
		var binary = File.new()
		binary.open("user://ardusub", File.READ)
		print(binary.get_path_absolute())
		print(OS.execute("chmod", ["+x", binary.get_path_absolute()], true))
		Globals.sitl_pid = OS.execute(binary.get_path_absolute(), ["-S","--model","JSON","--speedup","1","-I0","--home","33.810313,-118.39386700000001,0.0,270.0"], false)
		add_status("SITL is running")
		$HBoxContainer/Menu/Buttons.visible = true

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		OS.kill(Globals.sitl_pid)
		get_tree().quit()

func create_level_buttons(levels):
	for filename in levels.keys():
		var button = Button.new()
		button.text = levels[filename]
		button.add_font_override("font", $HBoxContainer/Menu/Buttons/poolLevel.get_font("font"))
		button.connect("pressed", self, "_on_customLevel_pressed", [filename])
		$HBoxContainer/Menu/Buttons.add_child(button)

func find_external_levels():
	var loader = LevelLoader.new()
	loader.ensure_levels_folder_exists()
	var levels = loader.list_available_external_levels()
	self.create_level_buttons(levels)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)
	find_external_levels()
	$HBoxContainer/Menu/Buttons.visible = false

	if OS.get_name() == "Windows":
		if not File.new().file_exists("user://ardusub.exe"):
			add_status("SITL binary not found, downloading...")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/ArduSub.elf", "user://ardusub.exe")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cyggcc_s-1.dll", "user://cyggcc_s-1.dll")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cygstdc++-6.dll", "user://cygstdc++-6.dll")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cygwin1.dll", "user://cygwin1.dll")
		else:
			_start_sitl()
	elif OS.get_name() == "X11":
		if not File.new().file_exists("user://ardusub"):
			download_file("https://firmware.ardupilot.org/Sub/latest/SITL_x86_64_linux_gnu/ardusub", "user://ardusub")
		else:
			_start_sitl()
	else:
		$HBoxContainer/Buttons.visible = true
		$HBoxContainer/Buttons/CheckBox.visible = false
		add_status("SITL not available for plataform: %s" % OS.get_name())

func _on_poolLevel_pressed():
	Globals.active_vehicle = "bluerovheavy"
	Globals.active_level = "res://levels/pool.tscn"
	SceneLoader.goto_scene("res://levels/baselevel.tscn")

func _on_CheckBox_toggled(button_pressed):
	Globals.wait_SITL = button_pressed

func _on_customLevel_pressed(filename):
	Globals.active_vehicle = "bluerovheavy"
	Globals.active_level = "res://custom_level.tscn"
	ProjectSettings.load_resource_pack("res://levels/" + filename)
	SceneLoader.goto_scene("res://levels/baselevel.tscn")

func _on_licences_pressed():
	licences_popup.show()
