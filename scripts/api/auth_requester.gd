extends "res://scripts/api/requester.gd"
class_name AuthRequester

var username: String
var password: String


func request() -> void:
	errors.clear()
	var url: String = str(APIManager.URL_LOGIN, "wp-json/wp/v2/posts")
	var headers: PoolStringArray = [
		str("Authentification: Basic base64encoded ", Marshalls.utf8_to_base64("%s:%s" % [username, password]))
	]
	print(headers)
	var error: int = http_request.request(url, headers, APIManager.SSL_VALIDATE_DOMAIN, HTTPClient.METHOD_POST)
	if error != OK:
		printerr("Error occured while executing auth request")


func _init(username: String, password: String) -> void:
	self.username = username
	self.password = password


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var can_parse: bool = check_result(result)
	if not can_parse:
		errors.append(result)
		emit_signal("failed")
		return
	
	var json: Dictionary = parse_json(body.get_string_from_utf8())
	match response_code:
		200:
			emit_signal("success")
		_:
			if json.has("error"):
				errors = [json.error, json.error_description]
				print("returned: ", errors)
			emit_signal("failed")
