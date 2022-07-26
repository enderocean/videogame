extends "res://scripts/api/requester.gd"
class_name ScoreRequester

var username: String
var level: String
var time: int
var score: int

func request() -> void:
	var url: String = str(APIManager.URL_LOGIN, "wp-json/wp/v2/posts")
	var headers: PoolStringArray = [
		str("Authentification: Basic base64encoded ", Marshalls.utf8_to_base64("%s:%s" % [APIManager.KEY, APIManager.SECRET])),
		"Content-Type: application/json",
	]
	print(headers)
	var error: int = http_request.request(url, headers, APIManager.SSL_VALIDATE_DOMAIN, HTTPClient.METHOD_POST)
	if error != OK:
		printerr("Error occured while executing score request")


func _init(username: String, level: String, time: int, score: int) -> void:
	self.username = username
	self.level = level
	self.time = time
	self.score = score


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:	
	match response_code:
		200:
			emit_signal("success")
		_:
			var json: Dictionary = parse_json(body.get_string_from_utf8())
			if json.has("error"):
				error = json.error
			emit_signal("failed")
