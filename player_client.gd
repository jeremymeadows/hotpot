extends Control

var hand = []
var card = null

func _ready():
	#name = str(get_multiplayer_authority())
	#$VBoxContainer/Label.text = "Scan QR to join."
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Network.ADDRESS, Network.PORT)
	multiplayer.multiplayer_peer = peer
	
	if not Network.username:
		Network.username = "Player %s" % multiplayer.get_unique_id()
	
	await multiplayer.connected_to_server
	Network.update_username.rpc_id(1, Network.username)
	
	$Status.text = "Connected, waiting for game to start\nPlayer %s" % multiplayer.get_unique_id()
	Network.current_turn.connect(_on_turn)
	Network.updated_pot.connect(_update_pot)
	Network.game_over.connect(_game_over)
	
	hand = await Network.dealt_hand
	$Status.text = "Game Started!\nPlayer %s" % multiplayer.get_unique_id()
	
	$Deck.visible = true
	$Cards.visible = true
	
	#$Deck/AnimationPlayer.play("RESET")
	#$Deck.card = "none"
	
	for i in range(len(hand)):
		await get_tree().create_timer(0.5).timeout
		$Cards.get_child(i).card = hand[i]
	
	$New.pressed.connect(_play_card.bind(8))


func _on_turn():
	print('my turn')
	$Deck.pressed.connect(_draw_card.bind(null))
	
	for i in range(4):
		$Pot.get_child(i).pressed.connect(_draw_card.bind(i))
	
	for i in range(len(hand)):
		$Cards.get_child(i).pressed.connect(_play_card.bind(i))
	
	$Status.text = "Your Turn!\nPlayer %s" % multiplayer.get_unique_id()


func _draw_card(i):
	$Deck.pressed.disconnect(_draw_card)
	Network.draw_card.rpc_id(1, i)
	card = await Network.drew_card
	$New.card = card
	$New.visible = true


func _play_card(ndx):
	Network.play_card.rpc_id(1, ndx)
	$New.visible = false
	if ndx < len(hand):
		$Cards.get_child(ndx).card = card
	$Status.text = "Waiting for your turn...\nPlayer %s" % multiplayer.get_unique_id()
	
	for i in range(4):
		$Pot.get_child(i).pressed.disconnect(_draw_card)
	
	for i in range(len(hand)):
		$Cards.get_child(i).pressed.disconnect(_play_card)


func _update_pot(pot):
	for i in range(len(pot)):
		if pot[i] == null:
			$Pot.get_child(i).card = "none"
			get_tree().create_timer(0.5).timeout.connect(func(): $Pot.get_child(i).visible = false)
		else:
			$Pot.get_child(i).visible = true
			$Pot.get_child(i).card = pot[i]
			#$Pot.get_child(i).visible = true

func _game_over():
	pass
