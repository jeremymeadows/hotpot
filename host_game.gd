extends Control

var players = {}
var deck = Cards.get_deck()
var discards = []

var order = []
var turn = 0
var winner = null

var pot = []


func _ready():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Network.PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	print(multiplayer.get_unique_id())
	
	print(multiplayer.get_peers())
	
	host_lan()
	
	var join_text = "%s:%s" % [Network.ADDRESS, Network.PORT]
	$Menu/Label.text = "Server started. Join with QR code (IP: %s)" % join_text
	
	deck.shuffle()
	
	$Menu/Start.pressed.connect(_on_game_start)

func host_lan():
	_on_player_connected(1)

func game_loop():
	await get_tree().create_timer(4).timeout
	while true:
		await get_tree().create_timer(1).timeout
		
		# notify whose turn
		Network.next_turn.rpc_id(order[turn])
		# wait for draw pile selection
		var draw = await Network.drew_card
		if pot[turn] != null:
			discards += [pot[turn]]
		
		if draw == null:
			pot[turn] = deck.pop_back()
			#$Pot.get_child(turn).card = pot[turn]
			Network.draw_card.rpc_id(order[turn], pot[turn])
		elif draw in range(len(players)):
			pot[turn] = pot[draw]
			pot[draw] = null
			#$Pot.get_child(turn).card = pot[turn]
			#$Pot.get_child(draw).card = ""
			Network.draw_card.rpc_id(order[turn], pot[turn])
		Network.update_pot.rpc(pot)
		
		winner = check_win()
		if winner:
			break
		
		# wait for discard selection
		var i = await Network.played_card
		if i in range(8):
			var prev = players[order[turn]]["hand"][i]
			players[order[turn]]["hand"][i] = pot[turn]
			pot[turn] = prev
			$Pot.get_child(turn).card = pot[turn]
		Network.update_pot.rpc(pot)
		
		turn = (turn + 1) % len(order)
		if len(deck) == 0:
			discards.shuffle()
			deck = discards
			discards = []
	$Label.text += "\nPlayer %s wins!" % order[turn]


func check_win():
	var hand = players[order[turn]]["hand"] + [pot[turn]]
	return Cards.check_complete(hand)


func _on_player_connected(id):
	var username = await Network.set_username
	players[id] = {"name": username, "hand": []}
	$Menu/Start.text = "Start (%d/4)" % len(players)
	print(players)
	$Menu/Label.text += "\n%s joined!" % username
	
	for _i in range(8):
		players[id].hand += [deck.pop_back()]


func _on_game_start():
	$Menu.visible = false
	#$Player.visible = true
	for id in players:
		Network.deal_hand.rpc_id(id, players[id].hand)
	order = players.keys()
	order.shuffle()
	pot.resize(len(players))
	pot.fill(null)
	game_loop()


func _on_player_disconnected(id):
	players.erase(id)
	$Menu/Label.text += "\n%s disconnected." % players[id]["name"]


#func _generate_qr(text: String):
	#var qr = preload("res://addons/qrcodegen.gd").new()
	#var img = qr.make_image(text)
	#var tex = ImageTexture.create_from_image(img)
	#$TextureRect.texture = tex
#
#func _get_local_ip() -> String:
	#var ips = IP.get_local_addresses()
	#for ip in ips:
		#if ip.find("192.168.") == 0 or ip.find("10.") == 0:
			#return ip
	#return "127.0.0.1"
