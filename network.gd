extends Node

const ADDRESS = "127.0.0.1"
const PORT = 9000

signal dealt_hand(hand: Array[String])
signal drew_card(card: String)
signal played_card(card: String)
signal current_turn
signal game_over(winner: String)
signal set_username(name: String)
signal updated_pot(pot: Array[String])

var username = null


@rpc("authority", "call_remote", "reliable")
func deal_hand(cards):
	dealt_hand.emit(cards)

@rpc("any_peer", "call_remote", "reliable")
func draw_card(card):
	drew_card.emit(card)

@rpc("any_peer", "call_remote", "reliable")
func play_card(card):
	played_card.emit(card)

@rpc("authority", "call_remote", "reliable")
func next_turn():
	current_turn.emit()

@rpc("authority", "call_remote", "reliable")
func update_pot(pot):
	updated_pot.emit(pot)

@rpc("any_peer", "call_remote", "reliable")
func update_username(username):
	set_username.emit(username)
