extends Spatial
class_name CollectibleTag

export var id: String


func _ready() -> void:
	if not get_parent() is DeliveryObject:
		printerr(name, "'s parent is not a DeliveryObject")
		return
	
	if id.empty():
		printerr(name, "'s id cannot be empty")
		return

	add_to_group("collectible_tags")
	var delivery_object: DeliveryObject = get_parent()
	delivery_object.connect("delivered", self, "_on_delivered")


func _on_delivered() -> void:
	SaveManager.data.collectibles[id] = true
