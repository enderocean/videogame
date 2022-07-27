extends "res://scripts/api/requester.gd"
class_name TokenLeaderboardRequester

var token: String

func request() -> void:
	var url: String = str(APIManager.leaderboard_url, "api/getToken")
	var headers: PoolStringArray = [
		"Content-Type: application/json",
		str("Authorization: Basic ", Marshalls.utf8_to_base64("%s:%s" % [APIManager.leaderboard_key, APIManager.leaderboard_secret]))
	]
	
	print(url)
	print(headers)
	
	var error: int = http_request.request(url, headers, APIManager.SSL_VALIDATE_DOMAIN, HTTPClient.METHOD_GET)
	if error != OK:
		printerr("Error occured while executing auth request")


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	._on_request_completed(result, response_code, headers, body)
	if not result == HTTPRequest.RESULT_SUCCESS:
		return
	
	var json = parse_json(body.get_string_from_utf8())
	match response_code:
		200:
			if not json.has("token"):
				printerr("Token not found in the response JSON.")
				return
			token = json.token
			emit_signal("completed", true)
		_:
			if json.has("error"):
				error = json.error
			emit_signal("completed", false)
