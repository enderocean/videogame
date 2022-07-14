extends "res://scripts/api/requester.gd"
class_name AuthRequester

var url: String
var username: String
var password: String


func request() -> void:
	var url: String = str(APIManager.URL_LOGIN, "wp-json/wp/v2/posts")
	var headers: PoolStringArray = [
		str("Authentification: Basic base64encoded ", Marshalls.utf8_to_base64("%s:%s" % [username, password]))
	]
	print(headers)
	var error: int = http_request.request(url, headers, true, HTTPClient.METHOD_POST)
	if error != OK:
		printerr("Error occured while executing auth request")

func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	match response_code:
		200:
			pass
		400:
			pass
		401:
			pass
