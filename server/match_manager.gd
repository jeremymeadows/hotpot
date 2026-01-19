extends Node

# match_instance.gd
var player_data = {} # Map of ID -> Player Stats

func setup_game(roster: Array):
	for id in roster:
		var is_bot = (id < 0)
		player_data[id] = {"is_bot": is_bot, "score": 0, "hand": []}
		
	# Tell the human clients to load the game scene
	for id in roster:
		if id > 0: # Only send to real people
			rpc_id(id, "client_load_game", roster)
			
	start_first_turn()

func next_turn(current_id):
	if player_data[current_id].is_bot:
		_run_bot(current_id)
	else:
		# Wait for RPC from client or timeout if they go AFK
		start_turn_timer(current_id)

func _run_bot(bot_id):
	await get_tree().create_timer(1.5).timeout # Small delay so it feels natural
	# AI logic here...
	print("Bot %d is playing a card..." % bot_id)
	execute_move(bot_id, choose_best_card(bot_id))
