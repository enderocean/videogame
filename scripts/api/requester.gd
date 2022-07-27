extends Node

var http_request: HTTPRequest
var error: String

signal completed(success)

func request() -> void:
	error = ""


func _ready() -> void:
	# Execute request
	http_request = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_completed")
	add_child(http_request)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var can_parse: bool = result == HTTPRequest.RESULT_SUCCESS
	if not can_parse:
		match result:
			HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
				error = "RESULT_CHUNKED_BODY_SIZE_MISMATCH"
			HTTPRequest.RESULT_CANT_CONNECT:
				error = "RESULT_CANT_CONNECT"
			HTTPRequest.RESULT_CANT_RESOLVE:
				error = "RESULT_CANT_RESOLVE"
			HTTPRequest.RESULT_CONNECTION_ERROR:
				error = "RESULT_CONNECTION_ERROR"
			HTTPRequest.RESULT_SSL_HANDSHAKE_ERROR:
				error = "RESULT_SSL_HANDSHAKE_ERROR"
			HTTPRequest.RESULT_NO_RESPONSE:
				error = "RESULT_NO_RESPONSE"
			HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
				error = "RESULT_BODY_SIZE_LIMIT_EXCEEDED"
			HTTPRequest.RESULT_REQUEST_FAILED:
				error = "RESULT_REQUEST_FAILED"
			HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
				error = "RESULT_DOWNLOAD_FILE_CANT_OPEN"
			HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
				error = "RESULT_DOWNLOAD_FILE_WRITE_ERROR"
			HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
				error = "RESULT_REDIRECT_LIMIT_REACHED"
			HTTPRequest.RESULT_TIMEOUT:
				error = "RESULT_TIMEOUT"
		
		emit_signal("completed", false)
