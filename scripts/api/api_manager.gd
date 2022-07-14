extends Node

const ENABLED: bool = true
const TEST: bool = true
const URL_LOGIN: String = "https://leaderboard.enderocean.com/"
const URL_LEADERBOARD: String = "https://leaderboard.enderocean.com/"
const URL_LEADERBOARD_TEST: String = "https://app-leaderboard.nodea.studio/"
const KEY: String = "t4m12tbJ0X2xs6N"
const SECRET: String = "UJPoKlYMAwy54IH"

var url_leaderboard: String
# Used for encrypted request
var HMAC: HMACContext

signal auth_completed()
signal auth_error(error)
signal score_completed()
signal score_error(error)


func request_auth(username: String, password: String) -> void:
	var requester: AuthRequester = AuthRequester.new()
	add_child(requester)
	requester.username = username
	requester.password = password
	requester.request()

func request_send_score() -> void:
	pass


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if TEST:
		url_leaderboard = URL_LEADERBOARD_TEST
	else:
		url_leaderboard = URL_LEADERBOARD

	HMAC = HMACContext.new()
