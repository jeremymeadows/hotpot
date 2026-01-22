extends Node

static var ADDRESS = "hotpot.jeremymeadows.dev"
static var PORT = 8000
static var PROTO = "wss"

# static var ADDRESS = "localhost"
# static var PORT = 8910
# static var PROTO = "ws"

func get_data() -> void:
	#DotEnv.load_env(".env")
	#ADDRESS = OS.get_environment("ADDRESS")
	#PORT = int(OS.get_environment("PORT"))
	#PROTO = OS.get_environment("PROTO")
	pass


@rpc("authority", "call_remote", "reliable")
func setup_client_room(room_name: String, players: Array):
	get_node("/root/Main/Waiting").queue_free()
	var match_scene = preload("res://client/match.tscn").instantiate()
	match_scene.name = room_name
	match_scene.players = players
	
	while players[0] != multiplayer.get_unique_id():
		players.push_back(players.pop_front())
	
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	match_scene.get_node("UI/Player2/Name").text = str(players[1])
	match_scene.get_node("UI/Player3/Name").text = str(players[2])
	match_scene.get_node("UI/Player4/Name").text = str(players[3])
	
	get_node("/root/Main/Matches").add_child(match_scene)
