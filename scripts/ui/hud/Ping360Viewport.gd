extends ViewportContainer

var sonar = null
var img = Image.new()
var last_points = []
var angle = 0


func _ready() -> void:
# warning-ignore:return_value_discarded
	Globals.connect("ping360_changed", self, "_on_ping360_changed")

	var sonars = get_tree().get_nodes_in_group("ping360")
	if len(sonars) == 0:
		print("unable to find ping360")
		return
	self.sonar = sonars[0]
# warning-ignore:return_value_discarded
	self.sonar.connect("updatePing360Display", self, "on_ping360_update")

	# You'll have to get thoose the way you want
	var array_width = 100
	var array_heigh = 360
	var array = []
	for _y in range(360):
		for _x in range(100):
			array.append(0)

	# The following is used to convert the array into a Texture
	var byte_array = PoolByteArray(array)

	# I don't want any mipmaps generated : use_mipmaps = false
	# I'm only interested with 1 component per pixel (the corresponding array value) : Format = Image.FORMAT_R8
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_R8, byte_array)


func _process(_delta: float) -> void:
	visible = Globals.ping360_enabled
	if not visible:
		return

	img.lock()
	for x in range(100):
		img.set_pixel(x, angle, 0)
	for point in last_points:
		var distance = point[0]
		var intensity = point[1]
		img.set_pixel(int(distance), angle, Color(intensity, intensity, intensity))

	img.unlock()
	#var image = texture.get_data()
	#img.set_pixel(angle, angle, 6)
	# Override the default flag with 0 since I don't want texture repeat/filtering/mipmaps/etc
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	# Upload the texture to my shader
	self.get_material().set_shader_param("my_array", texture)


func on_ping360_update(pingAngle, points) -> void:
	self.last_points = points
	self.angle = pingAngle


func _on_ping360_changed() -> void:
	visible = Globals.ping360_enabled
