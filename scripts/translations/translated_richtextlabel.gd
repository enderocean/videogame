extends RichTextLabel
class_name TranslatedRichTextLabel

# translation key saved
var key: String


func _ready() -> void:
	# Get the text as the translation key
	key = text
	# Set the correct text
	update_text()


func update_text() -> void:
	text = tr(key)
