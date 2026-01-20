extends Node

const MAX_PLAYERS = 4
const WAIT_TIME = 5.0

var queue: Array[int] = []
var lobby_timer: Timer

var active_games: Dictionary[String, Thread] = {}

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	lobby_timer = Timer.new()
	lobby_timer.one_shot = true
	lobby_timer.timeout.connect(_start_match)
	add_child(lobby_timer)

func _on_peer_connected(id):
	print("Player %d joined queue" % id)
	queue.append(id)
	if queue.size() == 1:
		lobby_timer.start(WAIT_TIME)
	if queue.size() >= MAX_PLAYERS:
		_start_match()

func _on_peer_disconnected(id):
	queue.erase(id)

func _start_match():
	print('server starting match')
	lobby_timer.stop()
	if queue.is_empty():
		return
	
	var players = []
	
	for id in queue.slice(0, MAX_PLAYERS):
		players += [queue.pop_front()]
	while len(players) < 4:
		var bot_id = -(len(players) + 100)
		players += [bot_id]
	
	var room_name = "Match_" + str(Time.get_ticks_msec())
	var match_scene = preload("res://server/manager.gd").new()
	match_scene.name = room_name
	
	# Isolate networking for this room
	var room_api = SceneMultiplayer.new()
	room_api.multiplayer_peer = multiplayer.multiplayer_peer
	
	get_node("/root/Main/Matches").add_child(match_scene)
	get_tree().set_multiplayer(room_api, match_scene.get_path())
	
	# Tell humans to join this specific path
	for id in players.filter(func(id): return id > 0):
		print('inviting ', id)
		Network.setup_client_room.rpc_id(id, room_name, players)
	
	match_scene.initialize_game(players)
	#match_scene.start_game()
	var game_thread = Thread.new()
	game_thread.start(match_scene.start_game)
	active_games[room_name] = game_thread
