extends Node

enum State { LOADING, WAITING, DRAWING, DISCARDING }

var current_state = State.LOADING:
	set(new_state):
		current_state = new_state
		play_turn()

var players = {}


func _ready():
	$RPC.dealt_hand.connect(func(hand):
		for i in range(8):
			$UI/Player1/MarginContainer/Cards.get_children()[i].card = hand[i]
		current_state = State.WAITING
	)
	
	$RPC.new_card.connect(func(card):
		$UI/New.card = card
		current_state = State.DISCARDING
	)
	
	$RPC.start_turn.connect(func(): current_state = State.DRAWING)
	
	$RPC.updated_pot.connect(func(player, card):
		$UI/Pot.get_child(players.keys().find(player)).card = card
	)
	
	$RPC.game_over.connect(func(winner, hands):
		$UI/GameOver.text = "You Win!" if winner == multiplayer.get_unique_id() else "%s Wins!" % players[winner]
		$UI/GameOver.visible = true
		
		for i in range(1, 4):
			var player = $UI.get_child(i + 2).get_node("MarginContainer/Cards")
			var hand = hands[players.keys()[i]].hand
			for j in range(8):
				player.get_child(j).card = hand[j]
		
		current_state = State.WAITING
	)
	
	
	$UI/Draw.pressed.connect(func():
		$RPC.draw_card.rpc_id(1, 0)
	)
	
	$UI/New.pressed.connect(func():
		$RPC.play_card.rpc_id(1, 0)
		$UI/New.card = "none"
		current_state = State.WAITING
	)
	
	var cards = $UI/Player1/MarginContainer/Cards.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.play_card.rpc_id(1, i + 1)
			cards[i].card = $UI/New.card
			$UI/New.card = "none"
			current_state = State.WAITING
		)
	cards = $UI/Pot.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.draw_card.rpc_id(1, players.keys()[i])
			current_state = State.DISCARDING
		)
	
	$UI/Status/Timer.timeout.connect(func():
		match current_state:
			State.DRAWING:
				$RPC.draw_card.rpc_id(1, 0)
				await $RPC.new_card
				$RPC.play_card.rpc_id(1, 0)
				$UI/New.card = "none"
				current_state = State.WAITING
			State.DISCARDING:
				$RPC.play_card.rpc_id(1, 0)
				$UI/New.card = "none"
				current_state = State.WAITING
			_: pass
	)


func play_turn():
	match current_state:
		State.LOADING, State.WAITING:
			$UI/Status.visible = false
			disable_interactions()
		State.DRAWING:
			$UI/Status/Timer.start()
			$UI/Status.text = "Your turn: draw a card"
			$UI/Status.visible = true
			enable_draw_interactions()
		State.DISCARDING:
			$UI/Status.text = "Your turn: discard a card"
			enable_discard_interactions()


func disable_interactions():
	$UI/Draw.disabled = true
	for card in $UI/Pot.get_children().slice(1):
		card.disabled = true
	$UI/New.disabled = true
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = true
		
func enable_draw_interactions():
	disable_interactions()
	$UI/Draw.disabled = false
	for card in $UI/Pot.get_children().slice(1):
		if card.card != "none":
			card.disabled = false
	
func enable_discard_interactions():
	disable_interactions()
	$UI/New.disabled = false
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = false


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://client/menu.tscn")
