extends Node

#@rpc("authority")
#func setup_client_room(room_name: String, _human_ids: Array):
	#print("Joining room: ", room_name)
	#var match_scene = preload("res://common/match.tscn").instantiate()
	#match_scene.name = room_name
	#
	#var room_api = SceneMultiplayer.new()
	#room_api.multiplayer_peer = multiplayer.multiplayer_peer
	#
	#get_node("/root/Main/Matches").add_child(match_scene)
	#get_tree().set_multiplayer(room_api, match_scene.get_path())
	
	# Now this match_scene is isolated from other matches!
