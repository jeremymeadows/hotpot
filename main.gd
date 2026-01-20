extends Node

const PORT = 8910
const ADDRESS = "127.0.0.1"

func _ready():
	# If the binary is exported as a dedicated server...
	if "--help" in OS.get_cmdline_user_args():
		print('todo: help')
		get_tree().quit()
	
	if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		print("--- Starting Server ---")
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_server(PORT)
		multiplayer.multiplayer_peer = peer
		
		# Add the Server Matchmaker logic
		var server = preload("res://server/server.gd").new()
		#server.name = "NetworkHandler"
		add_child(server)
	else:
		print("--- Starting Client ---")
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_client("ws://" + ADDRESS + ":" + str(PORT))
		multiplayer.multiplayer_peer = peer
		
		# Add the Client logic
		#var client = preload("res://client/game.gd").new()
		#client.name = "NetworkHandler"
		#add_child(client)
