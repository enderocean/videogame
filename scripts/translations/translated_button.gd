extends Button
class_name TranslatedButton

export var uppercase: bool = false setget set_uppercase

# translation key saved
var key: String
# keeps the original translated text in case of not uppercase
var original_text: String

func _ready() -> void:
	# Get the text as the translation key
	key = text
	# Set the correct text
	update_text()
	set_uppercase(uppercase)


func update_text() -> void:
	original_text = tr(key)
	text = original_text


func set_uppercase(value: bool) -> void:
	uppercase = value
	
	if value:
		text = original_text.to_upper()
	else:
		text = original_text
