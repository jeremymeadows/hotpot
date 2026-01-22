extends Node

func _ready():
	if "--help" in OS.get_cmdline_user_args():
		print('todo: help')
		get_tree().quit()
	
	Network.get_data()
	
	if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
		print("Server starting on 0.0.0.0:", Network.PORT)
		var peer = WebSocketMultiplayerPeer.new()
		peer.create_server(8910)
		multiplayer.multiplayer_peer = peer
		
		var server = preload("res://server/server.gd").new()
		server.name = "Server"
		add_child(server)
	else:
		get_tree().call_deferred("change_scene_to_file", "res://client/menu.tscn")
