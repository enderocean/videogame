extends HTTPRequest

enum State { GET_TOKEN, SEND_SCORE, DONE }

var dns: String = "https://app-leaderboard.nodea.studio"
var clientKey: String = "t4m12tbJ0X2xs6N"
var clientSecret: String = "UJPoKlYMAwy54IH"
var token: String = ""

var state = State.DONE

signal done


func _ready() -> void:
	# Ensure this node is not being paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_use_threads(false)
	connect("request_completed", self, "on_request_completed")


func send_score() -> void:
	# Get the token first
	state = State.GET_TOKEN
	var auth: String = str("Basic ", Marshalls.utf8_to_base64(str(clientKey, ":", clientSecret)))
	var headers: Array = ["Content-Type: application/json", "Authorization: " + auth]
	request(dns + "/api/getToken", headers, true)


func on_request_completed(
	result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray
) -> void:
	var data = body.get_string_from_utf8()
	var json: Dictionary = parse_json(data)
	print(data)

	match state:
		State.GET_TOKEN:
			if not json.has("token"):
				printerr("Token not found.")
				return

			token = json.token

			# Send the score after getting the token
			state = State.SEND_SCORE
			var h: Array = ["Content-Type: application/json"]
			var q: Dictionary = {
				"f_player": Globals.user_data.name, "f_score": Globals.user_data.score
			}
			request(
				dns + "/api/leaderboard/?token=" + token,
				h,
				true,
				HTTPClient.METHOD_POST,
				JSON.print(q)
			)

		State.SEND_SCORE:
			state = State.DONE
			emit_signal("done")
