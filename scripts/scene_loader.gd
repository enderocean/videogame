extends Node

# Reference: https://docs.godotengine.org/en/3.0/tutorials/io/background_loading.html#doc-background-loading

var current_scene = null
var loader: ResourceInteractiveLoader = null

var time_max: int = 1000 / 16 # ms
# Control loading scene
var wait_frames: int = 0

var label: Label

func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

func goto_scene(path: String) -> void:
	loader = ResourceLoader.load_interactive(path)
	if not loader: 
		print("Could not start to load: %s" % path)
		return

	set_process(true)

	# get rid of the old scene
	current_scene.queue_free()

	var error = get_tree().change_scene("res://scenes/ui/loading.tscn")
	if error != OK:
		print("Error while loading scene: %s" % error)
	wait_frames = 1

func _process(_delta: float) -> void:
	if not loader:
		# no need to process anymore
		set_process(false)
		return

	# wait for frames to let the "loading" animation to show up
	if wait_frames > 0: 
		wait_frames -= 1
		return

	var time: int = OS.get_ticks_msec()
	while OS.get_ticks_msec() < time + time_max: # use "time_max" to control how much time we block this thread

		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			print("Error during loading scene")
			loader = null
			break

func update_progress() -> void:
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	var loading_scene = get_tree().get_current_scene()
	
	if not label:
		label = loading_scene.get_node("Label")
	
	label.text = "Loading.. (%d %%)" % (progress * 100)

func set_new_scene(scene_resource: PackedScene) -> void:
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
