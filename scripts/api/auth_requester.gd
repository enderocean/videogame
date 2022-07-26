extends "res://scripts/api/requester.gd"
class_name AuthRequester

var username: String
var password: String


func request() -> void:
	var url: String = str(APIManager.URL_LOGIN, "wp-json/wp/v2/posts")
	var headers: PoolStringArray = [
		str("Authorization:Basic ", Marshalls.utf8_to_base64("%s:%s" % [username, password]))
	]
	print(headers)
	var error: int = http_request.request(url, headers, APIManager.SSL_VALIDATE_DOMAIN, HTTPClient.METHOD_GET)
	if error != OK:
		printerr("Error occured while executing auth request")


func _init(username: String, password: String) -> void:
	self.username = username
	self.password = password


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	match response_code:
		200:
			emit_signal("completed", true)
		_:
			var json: Dictionary = parse_json(body.get_string_from_utf8())
			if json.has("error"):
				error = json.error
			emit_signal("completed", false)
	
	# Reset values
	username = ""
	password = ""
