extends Node

var players = []

signal next
signal next2

func _ready():
	#await $RPC.is_ready
	#$RPC.ready.rpc_id(1, multiplayer.get_unique_id())
	$UI/ID.text = name
	
	var cards = await $RPC.dealt_hand
	for i in range(8):
		$UI/Player1/Cards.get_children()[i].card = cards[i]
	$UI/Pot.visible = true
	
	$RPC.game_over.connect(func(winner):
		$UI/GameOver.text = "%s Wins!" % str(winner)
		$UI/GameOver.visible = true
		multiplayer.multiplayer_peer.disconnect_peer(1)
	)
	$RPC.updated_pot.connect(func(player, card):
		$UI/Pot.get_child(players.find(player)).card = card
	)
	
	$RPC.new_card.connect(func(card):
		$UI/New.card = card
		next.emit()
	)
	
	$UI/Draw.pressed.connect(func():
		$RPC.draw_card.rpc_id(1, 0)
	)
	$UI/New.pressed.connect(func():
		$RPC.play_card.rpc_id(1, 0)
		$UI/New.card = "none"
		next2.emit()
	)
	cards = $UI/Pot.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.draw_card.rpc_id(1, players[i])
			next.emit()
		)
	cards = $UI/Player1/Cards.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.play_card.rpc_id(1, i + 1)
			cards[i].card = $UI/New.card
			$UI/New.card = "none"
			next2.emit()
		)
	
	while true:
		await $RPC.start_turn
		draw_card()
		play_card()


func draw_card():
	$UI/Draw.disabled = false
	for card in $UI/Pot.get_children().slice(1):
		card.disabled = false
	await next
	$UI/Draw.disabled = true
	for card in $UI/Pot.get_children().slice(1):
		card.disabled = true

func play_card():
	$UI/Pot/Card1.disabled = false
	for card in $UI/Player1/Cards.get_children():
		card.disabled = false
	await next2
	$UI/Pot/Card1.disabled = true
	for card in $UI/Player1/Cards.get_children():
		card.disabled = true
