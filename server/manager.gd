extends Node

var players = {}

func initialize_game(ids: Array):
	# Fill with bots if less than 4
	#var final_roster = human_ids.duplicate()
	#while final_roster.size() < 4:
		#var bot_id = -(final_roster.size() + 100)
		#final_roster.append(bot_id)
	
	for id in ids:
		players[id] = { "ready": false, "hand": [], "pot": "none" }
	
	print("Room ", name, " initialized with players: ", players.keys())


func start_game():
	var deck = Cards.get_deck()
	deck.shuffle()
	var pot = ["none", "none", "none", "none"]
	
	#for id in players:
		#if id > 0:
			#players[id].ready = false
	#print('looking for readies')
	
	#Network.is_ready.connect(func (i): 
		#players_ready[i] = true
		#print('player ', i, ' ready')
	#)
	#
	#var timer = get_tree().create_timer(10)
	#var all_ready = true
	
	#while timer.time_left > 0:
		#print('trying for ', timer.time_left, ' seocnds')
		#Network.ready.rpc(1)
		#await get_tree().create_timer(1).timeout
		#all_ready = players_ready.values().all(func (e): return e)
	await get_tree().create_timer(2).timeout
	#if not players.values().map(func (e): return e.ready).all(func (e): return e):
		#print('lobby timed out')
		#get_tree().quit()
	
	print('dealing')
	for id in players:
		players[id].hand = deck.slice(0, 8)
		#players[id].hand.sort_custom(Cards.sort)
		if id > 0:
			Network.deal_hand.rpc_id(id, players[id].hand)
		deck = deck.slice(8)
	print(players)
	
	var turn = 0
	
	while true:
		if players.keys()[turn] > 0:
			Network.next_turn.rpc_id(players.keys()[turn])
		else:
			pot[turn] = deck.pop_front()
			await get_tree().create_timer(2).timeout
			Network.update_pot.rpc(players.keys()[turn], pot[turn])
			turn = (turn + 1) % len(players)
			continue
		print('player ', turn, ' turn')
		
		var card = "none"
		match await Network.drew_card:
			0:
				card = deck.pop_front()
			var loc:
				card = pot[players.keys().find(loc)]
				pot[players.keys().find(loc)] = "none"
				Network.update_pot.rpc(loc, "none")
		print('player ', turn, ' drew ', card)
		Network.deal_card.rpc_id(players.keys()[turn], card)
		
		if Cards.winning_hand(players[players.keys()[turn]].hand + [card]):
			print(players.keys()[turn], ' won')
			Network.game_won.rpc(players.keys()[turn])
			return
		
		match await Network.played_card:
			0: pot[turn] = card
			var c:
				pot[turn] = players[players.keys()[turn]].hand[c - 1]
				players[players.keys()[turn]].hand[c - 1] = card
		Network.update_pot.rpc(players.keys()[turn], pot[turn])
		print('player ', turn, ' discarded ', pot[turn])
		print(players[players.keys()[turn]].hand)
		
		if deck.is_empty():
			deck = Cards.get_deck()
			deck.shuffle()
		
		turn = (turn + 1) % len(players)
