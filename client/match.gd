extends Node

var players = {}

signal drew
signal discarded

func _ready():
	#$UI/ID.text = name
	
	#$UI/Player1/Name.text = str(players[0])
	#$UI/Player2/Name.text = str(players[1])
	#$UI/Player3/Name.text = str(players[2])
	#$UI/Player4/Name.text = str(players[3])
	
	#await $RPC.is_ready
	#$RPC.ready.rpc_id(1, multiplayer.get_unique_id())
	
	$RPC.game_over.connect(func(winner):
		$UI/GameOver.text = "You Win!" if winner == multiplayer.get_unique_id() else "%s Wins!" % players[winner]
		$UI/GameOver.visible = true
		multiplayer.multiplayer_peer.disconnect_peer(1)
	)
	$RPC.updated_pot.connect(func(player, card):
		$UI/Pot.get_child(players.keys().find(player)).card = card
	)
	
	$RPC.new_card.connect(func(card):
		$UI/New.card = card
		drew.emit()
	)
	
	$UI/Draw.pressed.connect(func():
		$RPC.draw_card.rpc_id(1, 0)
	)
	$UI/New.pressed.connect(func():
		$RPC.play_card.rpc_id(1, 0)
		$UI/New.card = "none"
		discarded.emit()
	)
	
	var cards = $UI/Player1/MarginContainer/Cards.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.play_card.rpc_id(1, i + 1)
			cards[i].card = $UI/New.card
			$UI/New.card = "none"
			discarded.emit()
		)
	cards = $UI/Pot.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.draw_card.rpc_id(1, players.keys()[i])
			drew.emit()
		)
	
	cards = await $RPC.dealt_hand
	for i in range(8):
		$UI/Player1/MarginContainer/Cards.get_children()[i].card = cards[i]
	
	
	while true:
		await $RPC.start_turn
		$UI/Status.visible = true
		draw_card()
		play_card()
		$UI/Status.visible = false


func draw_card():
	$UI/Draw.disabled = false
	for card in $UI/Pot.get_children().slice(1):
		if card.card != "none":
			card.disabled = false
	await drew
	$UI/Draw.disabled = true
	for card in $UI/Pot.get_children().slice(1):
		card.disabled = true

func play_card():
	$UI/New.disabled = false
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = false
	await discarded
	$UI/New.disabled = true
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = true
