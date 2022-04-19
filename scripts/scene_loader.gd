extends Node

# Reference: https://docs.godotengine.org/en/3.0/tutorials/io/background_loading.html#doc-background-loading

var current_scenes: Array
var loading_queue: Array
var loading_scene: Node

var loader: ResourceInteractiveLoader = null

# ms
var time_max: int = 1000 / 16
var wait_frames: int = 0

var label: Label
var root: Node

signal scene_loaded
signal scenes_loaded


func _ready() -> void:
	# Ensure this node is not being paused
	pause_mode = Node.PAUSE_MODE_PROCESS

	root = get_tree().get_root()
	current_scenes.append({"path": "", "scene": root.get_child(root.get_child_count() - 1)})


func load_scene(path: String, additive: bool = false) -> void:
	# Make sure the game is unpaused before loading a scene
	if get_tree().paused:
		get_tree().paused = false

	for i in range(current_scenes.size()):
		if path == current_scenes[i].path:
			printerr("Scene already in the current scenes: ", path)
			return

	for i in range(loading_queue.size()):
		if path == loading_queue[i]:
			printerr("Scene already in the loading queue: ", path)
			return

	if not loading_scene:
		loading_scene = load("res://scenes/ui/loading.tscn").instance()
		root.add_child(loading_scene)

	loading_queue.append(path)

	if not additive:
		unload_scenes()

	set_process(true)
	wait_frames = 1


func reload_scenes() -> void:
	var scenes: Array
	for scene in current_scenes:
		scenes.append(scene.path)
	unload_scenes()

	load_scene(scenes[0])
	for i in range(1, scenes.size()):
		load_scene(scenes[i], true)


func unload_scenes() -> void:
	for i in range(current_scenes.size()):
		if current_scenes[i] and current_scenes[i].scene:
			current_scenes[i].scene.queue_free()
	current_scenes.clear()


func _process(_delta: float) -> void:
	# Not loading
	if not loader:
		if loading_queue.size() == 0:
			set_process(false)
			# Remove loading node from the tree
			if loading_scene:
				root.remove_child(loading_scene)
			return

		if not loading_scene.is_inside_tree():
			root.add_child(loading_scene)

		# Try create resource loader
		loader = ResourceLoader.load_interactive(loading_queue[0])
		if not loader:
			print("Could not start to load: %s" % loading_queue[0])
			loading_queue.remove(0)
			return

	# wait for frames to let the "loading" animation to show up
	if wait_frames > 0:
		wait_frames -= 1
		return

	var time: int = OS.get_ticks_msec()
	while OS.get_ticks_msec() < time + time_max:  # use "time_max" to control how much time we block this thread
		# poll your loader
		var error: int = loader.poll()

		# loaded
		if error == ERR_FILE_EOF:
			var resource: PackedScene = loader.get_resource()
			set_new_scene(resource)
			loader = null
			break
		# loading
		elif error == OK:
			update_progress()
		# error during loading
		else:
			printerr("Error during loading scene")
			loader = null
			break


func update_progress() -> void:
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	if not label:
		label = loading_scene.get_node("Label")

	label.text = "Loading.. (%d %%)" % (progress * 100)


func set_new_scene(scene_resource: PackedScene) -> void:
	print("loaded: ", scene_resource.resource_path)

	var scene = scene_resource.instance()
	root.add_child(scene)

	var scene_data: Dictionary = {"path": loading_queue[0], "scene": scene}
	current_scenes.append(scene_data)
	loading_queue.remove(0)

	root.remove_child(loading_scene)
	root.add_child(loading_scene)
	emit_signal("scene_loaded", scene_data)
