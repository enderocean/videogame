extends Node

const ENABLED: bool = true
const TEST: bool = true
const URL_PRODUCTION: String = "https://leaderboard.enderocean.com/"
const URL_TEST: String = "https://app-leaderboard.nodea.studio/"
const KEY: String = "t4m12tbJ0X2xs6N"
const SECRET: String = "UJPoKlYMAwy54IH"

var url: String
# Used for encrypted request
var HMAC: HMACContext

signal auth_completed()
signal auth_error(error)
signal score_completed()
signal score_error(error)


func request_auth(username: String, password: String) -> void:
	var requester = 


func request_send_score() -> void:
	pass


func check_result(result: int) -> void:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			print("request succeeded")
		HTTPRequest.RESULT_REQUEST_FAILED:
			print("request failed")
		HTTPRequest.RESULT_TIMEOUT:
			print("request timedout")


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if TEST:
		url = URL_TEST
	else:
		url = URL_PRODUCTION

	HMAC = HMACContext.new()


func _on_request_auth_completed(http_request: HTTPRequest, result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	check_result(result)
	
	match response_code:
		200:
			pass
		400:
			pass
		401:
			pass
