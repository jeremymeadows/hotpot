extends Node

const ADDRESS = "127.0.0.1"
const PORT = 8910

#signal is_ready(id: int)
#signal dealt_hand(hand: Array[String])
#
#signal start_turn
#
#signal drew_card(from: int)
#signal new_card(card: String)
#signal played_card(card: int)
#
#signal updated_pot(player: int, card: String)
#signal game_over(winner: int)


@rpc("authority", "call_remote", "reliable")
func setup_client_room(room_name: String, players: Array):
	print("Joining room: ", room_name)
	get_node("/root/Main/Waiting").queue_free()
	var match_scene = preload("res://common/match.tscn").instantiate()
	match_scene.name = room_name
	match_scene.players = players
	
	while players[0] != multiplayer.get_unique_id():
		players.push_back(players.pop_front())
	
	match_scene.get_node("UI/Player1/Name").text = str(players[0])
	match_scene.get_node("UI/Player2/Name").text = str(players[1])
	match_scene.get_node("UI/Player3/Name").text = str(players[2])
	match_scene.get_node("UI/Player4/Name").text = str(players[3])
	
	#var room_api = SceneMultiplayer.new()
	#room_api.multiplayer_peer = multiplayer.multiplayer_peer
	
	get_node("/root/Main/Matches").add_child(match_scene)
	#get_tree().set_multiplayer(room_api, match_scene.get_path())

#@rpc("any_peer", "call_remote", "reliable")
#func ready(id):
	#is_ready.emit(id)
#
#@rpc("authority", "call_remote", "reliable")
#func deal_hand(cards):
	#dealt_hand.emit(cards)
#
#@rpc("authority", "call_remote", "reliable")
#func next_turn():
	#start_turn.emit()
#
#
#@rpc("any_peer", "call_remote", "reliable")
#func draw_card(from):
	#drew_card.emit(from)
#
#@rpc("authority", "call_remote", "reliable")
#func deal_card(card):
	#new_card.emit(card)
#
#@rpc("any_peer", "call_remote", "reliable")
#func play_card(card):
	#played_card.emit(card)
#
#
#@rpc("authority", "call_remote", "reliable")
#func update_pot(player, pot):
	#updated_pot.emit(player, pot)
#
#@rpc("authority", "call_remote", "reliable")
#func game_won(player):
	#game_over.emit(player)
