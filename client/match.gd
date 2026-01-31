extends Node

enum State { LOADING, WAITING, DRAWING, DISCARDING }

static func next_state(state: State) -> State:
	match state:
		State.LOADING: return State.WAITING
		State.WAITING: return State.DRAWING
		State.DRAWING: return State.DISCARDING
		State.DISCARDING: return State.WAITING
		_: return State.LOADING

var current_state = State.LOADING:
	set(new_state):
		current_state = new_state
		state_turn()

var players = {}

#signal drew
#signal discarded

func _ready():
	$RPC.dealt_hand.connect(func(hand):
		for i in range(8):
			$UI/Player1/MarginContainer/Cards.get_children()[i].card = hand[i]
		current_state = State.WAITING
	)
	
	$RPC.new_card.connect(func(card):
		$UI/New.card = card
		current_state = State.DISCARDING
		#drew.emit()
	)
	
	#$RPC.start_turn.connect(turn)
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
		#discarded.emit()
	)
	
	
	$UI/Draw.pressed.connect(func():
		$RPC.draw_card.rpc_id(1, 0)
	)
	
	$UI/New.pressed.connect(func():
		$RPC.play_card.rpc_id(1, 0)
		$UI/New.card = "none"
		current_state = State.WAITING
		#discarded.emit()
	)
	
	var cards = $UI/Player1/MarginContainer/Cards.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.play_card.rpc_id(1, i + 1)
			cards[i].card = $UI/New.card
			$UI/New.card = "none"
			current_state = State.WAITING
			#discarded.emit()
		)
	cards = $UI/Pot.get_children()
	for i in len(cards):
		cards[i].disabled = true
		cards[i].pressed.connect(func():
			$RPC.draw_card.rpc_id(1, players.keys()[i])
			current_state = State.DISCARDING
			#drew.emit()
		)
	
	$UI/Status/Timer.timeout.connect(func():
		match current_state:
			State.DRAWING:
				$RPC.draw_card.rpc_id(1, 0)
				$UI/Status/Timer/Timer.start(1)
			State.DISCARDING:
				$RPC.play_card.rpc_id(1, 0)
				$UI/New.card = "none"
				current_state = State.WAITING
			_: pass
	)

func turn():
	$UI/Status/Timer.start()
	
	$UI/Status.text = "Your turn: draw a card"
	$UI/Status.visible = true
	await draw_card()
	$UI/Status.text = "Your turn: discard a card"
	await play_card()
	$UI/Status.visible = false

func state_turn():
	match current_state:
		State.LOADING: pass
		State.WAITING:
			$UI/Status.visible = false
			$UI/New.disabled = true
			for card in $UI/Player1/MarginContainer/Cards.get_children():
				card.disabled = true
		State.DRAWING:
			$UI/Status/Timer.start()
			$UI/Status.text = "Your turn: draw a card"
			$UI/Status.visible = true
			
			$UI/Draw.disabled = false
			for card in $UI/Pot.get_children().slice(1):
				if card.card != "none":
					card.disabled = false
		State.DISCARDING:
			$UI/Status.text = "Your turn: discard a card"
			$UI/Draw.disabled = true
			for card in $UI/Pot.get_children().slice(1):
				card.disabled = true
			$UI/New.disabled = false
			for card in $UI/Player1/MarginContainer/Cards.get_children():
				card.disabled = false

func draw_card():
	$UI/Draw.disabled = false
	for card in $UI/Pot.get_children().slice(1):
		if card.card != "none":
			card.disabled = false
	#await drew
	$UI/Draw.disabled = true
	for card in $UI/Pot.get_children().slice(1):
		card.disabled = true

func play_card():
	$UI/New.disabled = false
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = false
	#await discarded
	$UI/New.disabled = true
	for card in $UI/Player1/MarginContainer/Cards.get_children():
		card.disabled = true


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://client/menu.tscn")
