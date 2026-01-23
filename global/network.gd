extends Node

static var PORT = 8910
static var SOCKET = "wss://hotpot.jeremymeadows.dev:8000"
#static var SOCKET = "ws://localhost:8910"

signal new_user(id: int, uname: String)


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
