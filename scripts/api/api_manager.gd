extends Node

const ENABLED: bool = true
const TEST: bool = true
const SSL_VALIDATE_DOMAIN: bool = true

var login_url: String
var leaderboard_url: String
var leaderboard_key: String
var leaderboard_secret: String
var leaderboard_token: String

signal auth_success()
signal auth_failed(error)
signal token_leaderboard_success()
signal token_leaderboard_error(error)
signal score_leaderboard_success()
signal score_leaderboard_error(error)


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
	# Get the leaderboard token if the client doesn't have it
	if leaderboard_token.empty():
		var token_requester: TokenLeaderboardRequester = TokenLeaderboardRequester.new()
		add_child(token_requester)
		token_requester.request()
		
		# Wait for the request to complete
		var success: bool = yield(token_requester, "completed")
		var error: String = token_requester.error
		var token: String = token_requester.token
		token_requester.queue_free()
		
		if success:
			leaderboard_token = token
			emit_signal("token_leaderboard_success")
			print("Token received: ", leaderboard_token)
		else:
			emit_signal("token_leaderboard_failed", error)
			printerr("Failed to get the token: ", error)
			return
	
	# Send the score
	var requester: ScoreRequester = ScoreRequester.new(username, level_id, time, score)
	add_child(requester)
	requester.request()
	
	# Wait for the request to complete
	var success: bool = yield(requester, "completed")
	var error: String = requester.error
	requester.queue_free()
	
	if success:
		emit_signal("score_leaderboard_success")
		print("Score sent with success")
	else:
		emit_signal("score_leaderboard_failed", error)
		printerr("Failed to send the score: ", error)


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	var config: ConfigFile = ConfigFile.new()
	var config_path: String = "res://api.cfg"
	var file: File = File.new()
	if not file.file_exists(config_path):
		# Write default config file
		config.set_value("LOGIN", "url", "https://..")
		config.set_value("LEADERBOARD", "url", "https://..")
		config.set_value("LEADERBOARD", "key", "apikey")
		config.set_value("LEADERBOARD", "secret", "apisecret")
		config.set_value("LEADERBOARD_TEST", "url", "https://..")
		config.set_value("LEADERBOARD_TEST", "key", "apikey")
		config.set_value("LEADERBOARD_TEST", "secret", "apisecret")
		config.save(config_path)
	else:
		var error: int = config.load(config_path)
		# If the file didn't load, ignore it.
		if error != OK:
			printerr("Could not load api.cfg file, file corrupted or not written correctly.")
			return
		
		# Get the leaderboard test section if testing
		var section: String = "LEADERBOARD"
		if TEST:
			section = "LEADERBOARD_TEST"
		
		# Get values from the config file
		leaderboard_url = config.get_value(section, "url", "")
		leaderboard_key = config.get_value(section, "key", "")
		leaderboard_secret = config.get_value(section, "secret", "")

