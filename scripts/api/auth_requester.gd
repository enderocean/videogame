extends "res://scripts/api/requester.gd"
class_name AuthRequester

var url: String
var username: String
var password: String

func request() -> void:
	var url: String = str(APIManager.url, "wp-json/wp/v2/posts")
	var headers: PoolStringArray = [
		str("Authentification: Basic base64encoded ", Marshalls.utf8_to_base64("%s:%s" % [username, password]))
	]
	http_request.request(url, headers)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	pass
	# TODO: Continue this when the API works
