extends Node

signal is_ready(id: int)
signal dealt_hand(hand: Array[String])

signal start_turn

signal drew_card(from: int)
signal new_card(card: String)
signal played_card(card: int)

signal updated_pot(player: int, card: String)
signal game_over(winner: int, all_cars: Array)


@rpc("any_peer", "call_remote", "reliable")
func ready(id):
	is_ready.emit(id)

@rpc("authority", "call_remote", "reliable")
func deal_hand(cards):
	dealt_hand.emit(cards)

@rpc("authority", "call_remote", "reliable")
func next_turn():
	start_turn.emit()


@rpc("any_peer", "call_remote", "reliable")
func draw_card(from):
	drew_card.emit(from)

@rpc("authority", "call_remote", "reliable")
func deal_card(card):
	new_card.emit(card)

@rpc("any_peer", "call_remote", "reliable")
func play_card(card):
	played_card.emit(card)


@rpc("authority", "call_remote", "reliable")
func update_pot(player, pot):
	updated_pot.emit(player, pot)

@rpc("authority", "call_remote", "reliable")
func game_won(player, cards):
	game_over.emit(player, cards)
