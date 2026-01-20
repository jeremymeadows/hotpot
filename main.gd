extends Node

func _ready():
	if "--help" in OS.get_cmdline_user_args():
		print('todo: help')
		get_tree().quit()
	
	if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		print("--- Starting Server ---")
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_server(Network.PORT)
		multiplayer.multiplayer_peer = peer
		
		var server = preload("res://server/server.gd").new()
		server.name = "Server"
		add_child(server)
	else:
		print("--- Starting Client ---")
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_client("ws://" + Network.ADDRESS + ":" + str(Network.PORT))
		multiplayer.multiplayer_peer = peer
