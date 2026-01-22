extends Node

var players = {}

func rpc_room(method: Callable, ...args):
	for id in players.keys().filter(func(e): return e > 0):
		method.rpc_id.callv([id] + args)


func initialize_game(ids: Array):
	# Fill with bots if less than 4
	#var final_roster = human_ids.duplicate()
	#while final_roster.size() < 4:
		#var bot_id = -(final_roster.size() + 100)
		#final_roster.append(bot_id)
	
	for id in ids:
		players[id] = { "name": "player %d" % id, "ready": false, "hand": [], "pot": "none" }
	
	print("Room ", name, " initialized with players: ", players.keys())

func start_game():
	var deck = Cards.get_deck()
	deck.shuffle()
	var pot = ["none", "none", "none", "none"]
	
	#for id in players:
		#if id > 0:
			#players[id].ready = false
	#print('looking for readies')
	
	#$RPC.is_ready.connect(func (i): 
		#players_ready[i] = true
		#print('player ', i, ' ready')
	#)
	#
	#var timer = get_tree().create_timer(10)
	#var all_ready = true
	
	#while timer.time_left > 0:
		#print('trying for ', timer.time_left, ' seocnds')
		#$RPC.ready.rpc(1)
		#await get_tree().create_timer(1).timeout
		#all_ready = players_ready.values().all(func (e): return e)
	await get_tree().create_timer(2).timeout
	#if not players.values().map(func (e): return e.ready).all(func (e): return e):
		#print('lobby timed out')
		#get_tree().quit()
	
	print('dealing')
	for id in players:
		players[id].hand = deck.slice(0, 8)
		if id > 0:
			$RPC.deal_hand.rpc_id(id, players[id].hand)
		deck = deck.slice(8)
	print(players)
	
	var turn = -1
	while true:
		turn = (turn + 1) % len(players)
		print('player ', players.keys()[turn], ' turn')
		
		if players.keys()[turn] > 0:
			$RPC.next_turn.rpc_id(players.keys()[turn])
		else:
			pot[turn] = deck.pop_front()
			await get_tree().create_timer(1).timeout
			rpc_room($RPC.update_pot, players.keys()[turn], pot[turn])
			continue
		
		var card = "none"
		match await $RPC.drew_card:
			0:
				card = deck.pop_front()
			var loc:
				card = pot[players.keys().find(loc)]
				pot[players.keys().find(loc)] = "none"
				rpc_room($RPC.update_pot, loc, "none")
		$RPC.deal_card.rpc_id(players.keys()[turn], card)
		
		if Cards.winning_hand(players[players.keys()[turn]].hand + [card]):
			print(players.keys()[turn], ' won')
			rpc_room($RPC.game_won, players.keys()[turn])
			return
		
		match await $RPC.played_card:
			0: pot[turn] = card
			var c:
				pot[turn] = players[players.keys()[turn]].hand[c - 1]
				players[players.keys()[turn]].hand[c - 1] = card
		rpc_room($RPC.update_pot, players.keys()[turn], pot[turn])
		
		if deck.is_empty():
			deck = Cards.get_deck()
			deck.shuffle()
