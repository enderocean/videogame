extends Node

var http_request: HTTPRequest


func request() -> void:
	pass


func _ready() -> void:
	# Execute request
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_auth_completed")
	add_child(http_request)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	http_request.queue_free()
