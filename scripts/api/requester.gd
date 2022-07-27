extends Node

var http_request: HTTPRequest
var error: String

signal completed(success)
signal success()
signal failed()

func request() -> void:
	error = ""


func check_result(result: int) -> bool:
	return result == HTTPRequest.RESULT_SUCCESS


func _ready() -> void:
	# Execute request
	http_request = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_completed")
	add_child(http_request)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var can_parse: bool = check_result(result)
	if not can_parse:
		error = HTTPRequest.Result.keys()[result]
		emit_signal("failed", false)
		return
