extends Node

## Handles everything related to SITL

var downloaded_files: Array = []

signal started
signal stopped

func _ready() -> void:
	# Ensure this node is not being paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	get_tree().set_auto_accept_quit(false)
	
	var file: File = File.new()
	if OS.get_name() == "Windows":
		if not file.file_exists("user://ardusub.exe"):
			print("SITL binary not found, downloading...")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/ArduSub.elf", "user://ardusub.exe")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cyggcc_s-1.dll", "user://cyggcc_s-1.dll")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cygstdc++-6.dll", "user://cygstdc++-6.dll")
			download_file("https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/cygwin1.dll", "user://cygwin1.dll")
	elif OS.get_name() == "X11":
		if not file.file_exists("user://ardusub"):
			print("SITL binary not found, downloading...")
			download_file("https://firmware.ardupilot.org/Sub/latest/SITL_x86_64_linux_gnu/ardusub", "user://ardusub")
	else:
		print("SITL not available for plataform: %s" % OS.get_name())
	
	_start_sitl()

func _start_sitl() -> void:
	var binary = File.new()
	
	if OS.get_name() == "Windows":
		binary.open("user://ardusub.exe", File.READ)
	elif OS.get_name() == "X11":
		binary.open("user://ardusub", File.READ)
		var error_code: int = OS.execute("chmod", ["+x", binary.get_path_absolute()], true)
		if error_code == -1:
			print("Error while chmod: %s", error_code)

	print("Executing: %s" % binary.get_path_absolute())
	Globals.sitl_pid = OS.execute(
		binary.get_path_absolute(),
		[
			"-S",
			"--model",
			"JSON",
			"--speedup",
			"1",
			"-I0",
			"--home",
			"33.810313,-118.39386700000001,0.0,270.0"
		], false)

	if Globals.sitl_pid == -1:
		print("Error while executing SITL: %s", Globals.sitl_pid)

	print("SITL (PID: %s) is running" % Globals.sitl_pid)
	emit_signal("started")

func _stop_sitl() -> void:
	# Try kill the SITL process
	var error = OS.kill(Globals.sitl_pid)
	if error != OK:
		print("Error while trying to kill SITL process: %s" % error)
	else:
		print("SITL stopped")
	
	emit_signal("stopped")

func download_file(url : String, file_name : String):
	print("downloading " + file_name)
	var http = HTTPRequest.new()
	add_child(http)
	http.set_download_file(file_name)
	http.request(url)
	http.connect("request_completed", self, "_on_download_finished", [file_name])

func _all_files_downloaded() -> bool:
	if OS.get_name() == "Windows":
		return len(downloaded_files) == 4
	elif OS.get_name() == "X11":
		return len(downloaded_files) == 1
	return false

func _on_download_finished(_result, _response_code, _headers, _body, file_name):
	print("Done downloading: %s", file_name)
	downloaded_files.append(file_name)
	if _all_files_downloaded():
		_start_sitl()

func _notification(what):
	# When the player requested to quit the game
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		# Wait for stop SITL
		_stop_sitl()
		# Quit the game
		get_tree().quit()
