extends Node
class_name CollectibleTag

export var id: String

signal obtained(id)

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
	# Check if the collectible id is valid (present in the collectible data) 
	if not Globals.collectibles.has(id):
		printerr('Collectible "', id, '" not found')
		return
	
	if not SaveManager.data.has("collectibles"):
		SaveManager.data["collectibles"] = {}
	
	# Save the collectible
	SaveManager.data.collectibles[id] = true
	
	emit_signal("obtained", id)
	
