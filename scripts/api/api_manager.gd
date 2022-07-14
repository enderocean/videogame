extends Node

const ENABLED: bool = true
const TEST: bool = true
const URL_LOGIN: String = "https://leaderboard.enderocean.com/"
const URL_LEADERBOARD: String = "https://leaderboard.enderocean.com/"
const URL_LEADERBOARD_TEST: String = "https://app-leaderboard.nodea.studio/"
const KEY: String = "t4m12tbJ0X2xs6N"
const SECRET: String = "UJPoKlYMAwy54IH"
const SSL_VALIDATE_DOMAIN: bool = true

var url_leaderboard: String
# Used for encrypted request
var HMAC: HMACContext
var token: String

signal auth_success()
signal auth_failed()
signal score_success()
signal score_error()


func request_auth(username: String, password: String) -> void:
	var requester: AuthRequester = AuthRequester.new(username, password)
	add_child(requester)
	requester.request()
	
	# Wait for the request to complete
	var success: bool = yield(requester, "completed")
	if success:
		emit_signal("auth_success")
	else:
		emit_signal("auth_failed")
	
	requester.queue_free()


func request_send_score(username: String, level_id: String, time: int, score: int) -> void:
	var requester: ScoreRequester = ScoreRequester.new(username, level_id, time, score)
	add_child(requester)
	requester.request()
	
	# Wait for the request to complete
	var success: bool = yield(requester, "completed")
	if success:
		emit_signal("auth_success")
	else:
		emit_signal("auth_failed")
	
	requester.queue_free()


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if TEST:
		url_leaderboard = URL_LEADERBOARD_TEST
	else:
		url_leaderboard = URL_LEADERBOARD

	HMAC = HMACContext.new()
