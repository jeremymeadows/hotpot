extends Node

const MAX_PLAYERS = 4
const WAIT_TIME = 5.0

const BOT_NAMES = [ "Ashura", "Auni", "Badruu", "Einar", "Elouisa", "Hekla", "Hodari", "Jel", "Jina", "Kenyatta", "Najuma", "Reth", "Tish", "Ulfe" ]

var queue: Array[int] = []
var lobby_timer: Timer = Timer.new()
var usernames: Dictionary[int, String] = {}

var active_games: Dictionary[String, Thread] = {}


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(func(id):
		usernames.erase(id)
		queue.erase(id)
	)
	
	Network.new_user.connect(func(id, uname):
		usernames[id] = uname
	)
	
	lobby_timer.timeout.connect(_start_match)
	add_child(lobby_timer)

func _on_peer_connected(id):
	print("Player %d joined queue" % id)
	queue.append(id)
	if queue.size() == 1:
		lobby_timer.start(WAIT_TIME)
	if queue.size() >= MAX_PLAYERS:
		lobby_timer.stop()
		_start_match()
		if len(queue) > 0:
			lobby_timer.start()

func _start_match():
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
	get_node("/root/Main/Matches").add_child(match_scene)
	
	var rpc_paths = preload('res://common/rpc.gd').new()
	rpc_paths.name = "RPC"
	match_scene.add_child(rpc_paths)
	
	var match_names = {}
	var bots = BOT_NAMES.duplicate()
	bots.shuffle()
	for id in players:
		match_names[id] = usernames[id] if id > 0 else bots.pop_front()
		#match_names[id] = "Player%d" % id if id > 0 else bots.pop_front()
	for id in players.filter(func(id): return id > 0):
		Network.setup_client_room.rpc_id(id, room_name, players, match_names)
	
	match_scene.initialize_game(players)
	
	var game_thread = Thread.new()
	game_thread.start(match_scene.start_game)
	active_games[room_name] = game_thread
