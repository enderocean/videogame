extends Button
class_name TranslatedButton

export var uppercase: bool = false

# translation key saved
var key: String
# keeps the original translated text in case of not uppercase
var original_text: String

func _ready() -> void:
	# Get the text as the translation key
	key = text
	# Set the correct text
	update_text()


func update_text() -> void:
	original_text = tr(key)
	text = original_text
	
	if uppercase:
		text = text.to_upper()

