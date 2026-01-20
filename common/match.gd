extends Node

var players = []

signal next
signal next2

func _ready():
	if not OS.has_feature("dedicated_server"):
		#await Network.is_ready
		#Network.ready.rpc_id(1, multiplayer.get_unique_id())
		$UI/ID.text = name
		
		print('waiting')
		var cards = await Network.dealt_hand
		print('got dealt ', cards)
		for i in range(8):
			$UI/Player1/Cards.get_children()[i].card = cards[i]
		$UI/Pot.visible = true
		
		Network.game_over.connect(func(winner):
			$UI/GameOver.text = "%s Wins!" % str(winner)
			$UI/GameOver.visible = true
			multiplayer.multiplayer_peer.disconnect_peer(1)
		)
		Network.updated_pot.connect(func(player, card):
			$UI/Pot.get_child(players.find(player)).card = card
		)
		
		Network.new_card.connect(func(card):
			print('drew', card)
			$UI/New.card = card
			next.emit()
		)
		
		$UI/Draw.pressed.connect(func():
			Network.draw_card.rpc_id(1, 0)
			print('drew from pile')
		)
		$UI/New.pressed.connect(func():
			Network.play_card.rpc_id(1, 0)
			$UI/New.card = "none"
			next2.emit()
		)
		cards = $UI/Pot.get_children()
		for i in len(cards):
			cards[i].disabled = true
			cards[i].pressed.connect(func():
				Network.draw_card.rpc_id(1, players[i])
				next.emit()
			)
		cards = $UI/Player1/Cards.get_children()
		for i in len(cards):
			cards[i].disabled = true
			cards[i].pressed.connect(func():
				Network.play_card.rpc_id(1, i + 1)
				cards[i].card = $UI/New.card
				$UI/New.card = "none"
				next2.emit()
			)
		
		while true:
			await Network.start_turn
			print('your turn!')
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
