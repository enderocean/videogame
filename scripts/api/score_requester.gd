extends "res://scripts/api/requester.gd"
class_name ScoreRequester

var username: String
var level: String
var time: int
var score: int

func request() -> void:
	var url: String = str(APIManager.leaderboard_url, "api/score/?token=", APIManager.leaderboard_token)
	var headers: PoolStringArray = [
		"Content-Type: application/json",
	]
	var json: String = JSON.print({
		"f_login": username,
		"f_niveau": level,
		"f_temps": time,
		"f_score": score
	})
	
	print(url)
	print(headers)
	
	var error: int = http_request.request(url, headers, APIManager.SSL_VALIDATE_DOMAIN, HTTPClient.METHOD_POST, json)
	if error != OK:
		printerr("Error occured while executing score request")


func _init(username: String, level: String, time: int, score: int) -> void:
	self.username = username
	self.level = level
	self.time = time
	self.score = score


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:	
	._on_request_completed(result, response_code, headers, body)
	if not result == HTTPRequest.RESULT_SUCCESS:
		return
	
	match response_code:
		200:
			emit_signal("completed", true)
		_:
			var json = parse_json(body.get_string_from_utf8())
			if json and json.has("error"):
				error = json.error
			emit_signal("completed", false)
