extends Node

const ADDRESS = "127.0.0.1"
const PORT = 9000

signal is_ready(id: int)
signal dealt_hand(hand: Array[String])

signal start_turn

signal drew_card(card: int)
signal new_card(card: String)
signal played_card(card: int)

#signal set_username(name: String)
signal updated_pot(pot: Array[String])
signal game_over(winner: String)

#var username = null

@rpc("authority", "call_remote", "reliable")
func setup_client_room(room_name: String, players: Array):
	print("Joining room: ", room_name)
	get_node("/root/Main/Waiting").queue_free()
	var match_scene = preload("res://common/match.tscn").instantiate()
	match_scene.name = room_name
	
	var room_api = SceneMultiplayer.new()
	room_api.multiplayer_peer = multiplayer.multiplayer_peer
	
	get_node("/root/Main/Matches").add_child(match_scene)
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	#add_child(match_scene)
	get_tree().set_multiplayer(room_api, match_scene.get_path())

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
func draw_card(card):
	drew_card.emit(card)

@rpc("authority", "call_remote", "reliable")
func deal_card(card):
	new_card.emit(card)

@rpc("any_peer", "call_remote", "reliable")
func play_card(card):
	played_card.emit(card)


@rpc("authority", "call_remote", "reliable")
func update_pot(pot):
	updated_pot.emit(pot)

#@rpc("any_peer", "call_remote", "reliable")
#func update_username(username):
	#set_username.emit(username)
