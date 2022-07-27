extends Node

const ENABLED: bool = true
const TEST: bool = true
const SSL_VALIDATE_DOMAIN: bool = true

# TODO: Read these in a config file ignored by git 
const URL_LOGIN: String = "https://www.enderocean.com/"
const URL_LEADERBOARD: String = "https://leaderboard.enderocean.com/"
const URL_LEADERBOARD_TEST: String = "https://app-leaderboard.nodea.studio/"
const KEY: String = "t4m12tbJ0X2xs6N"
const SECRET: String = "UJPoKlYMAwy54IH"

var url_leaderboard: String
var token: String

signal auth_success()
signal auth_failed(error)
signal score_success()
signal score_error(error)


func request_auth(username: String, password: String) -> void:
	var requester: AuthRequester = AuthRequester.new(username, password)
	add_child(requester)
	requester.request()
	
	# Wait for the request to complete
	var success: bool = yield(requester, "completed")
	if success:
		# Save user data
		# TODO: Save a token instead of user credentials please
		SaveManager.user["username"] = username
		SaveManager.user["password"] = password
		SaveManager.save_data()
		
		emit_signal("auth_success")
	else:
		emit_signal("auth_failed", requester.error)
	
	requester.queue_free()


func request_send_score(username: String, level_id: String, time: int, score: int) -> void:
	var requester: ScoreRequester = ScoreRequester.new(username, level_id, time, score)
	add_child(requester)
	requester.request()
	# Wait for the request to complete
	var success: bool = yield(requester, "completed")
	if success:
		emit_signal("score_success")
	else:
		emit_signal("score_failed", requester.error)
	
	requester.queue_free()


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if TEST:
		url_leaderboard = URL_LEADERBOARD_TEST
	else:
		url_leaderboard = URL_LEADERBOARD
