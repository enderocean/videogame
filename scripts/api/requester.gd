extends Node

var http_request: HTTPRequest


func request() -> void:
	pass


func check_result(result: int) -> bool:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			print("SUCCESS")
			return true
		HTTPRequest.RESULT_REQUEST_FAILED:
			printerr(get_class(), "REQUEST_FAILED")
		HTTPRequest.RESULT_TIMEOUT:
			printerr("TIMEOUT")
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			printerr("BODY_SIZE_LIMIT_EXCEEDED")
	return false


func _ready() -> void:
	# Execute request
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_auth_completed")
	add_child(http_request)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	http_request.queue_free()
