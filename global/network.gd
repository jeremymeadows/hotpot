extends Node

static var ADDRESS = "hotpot.jeremymeadows.dev"
static var PORT = 8000
static var PROTO = "wss"

#static var ADDRESS = "hotpot-ws.localhost"
#static var PORT = 443
#static var PROTO = "wss"

#static var ADDRESS = "localhost"
#static var PORT = 8910
#static var PROTO = "ws"

signal new_user(id: int, uname: String)


func get_data() -> void:
	#DotEnv.load_env(".env")
	#ADDRESS = OS.get_environment("ADDRESS")
	#PORT = int(OS.get_environment("PORT"))
	#PROTO = OS.get_environment("PROTO")
	pass


@rpc("authority", "call_remote", "reliable")
func setup_client_room(match_name: String, player_ids: Array, usernames: Dictionary):
	get_tree().change_scene_to_file('res://client/match.tscn')
	
	await get_tree().scene_changed
	var match_instance = get_node("/root/Main/Matches/Match")
	match_instance.name = match_name
	
	while player_ids[0] != multiplayer.get_unique_id():
		player_ids.push_back(player_ids.pop_front())
	
	var players = {}
	for id in player_ids:
		players[id] = usernames[id]
	match_instance.players = players
	
	match_instance.get_node("UI/ID").text = match_name
	for node in match_instance.find_children("Name"):
		node.text = usernames[player_ids.pop_front()]


@rpc("any_peer", "call_remote", "reliable")
func set_username(uname: String):
	new_user.emit(multiplayer.get_remote_sender_id(), uname)
