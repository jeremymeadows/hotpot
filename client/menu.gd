extends Control

static var arrow = load('res://assets/cursor_arrow.png')
static var pointer = load('res://assets/cursor_pointer.png')
static var beam = pointer


func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(pointer, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)


func _on_host_pressed() -> void:
	get_tree().change_scene_to_file('res://host_game.tscn')


func _on_join_pressed() -> void:
	get_tree().change_scene_to_file('res://player_client.tscn')


func _on_rules_pressed() -> void:
	$Rules.visible = true


func _on_close_pressed() -> void:
	$Rules.visible = false


func _on_quick_play_pressed() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	var conn = "%s://%s:%d" % [Network.PROTO, Network.ADDRESS, Network.PORT]
	
	print("Client connecting to `%s`" % conn)
	peer.create_client(conn)
	multiplayer.multiplayer_peer = peer
	
	$Start.visible = false
	$Waiting.visible = true
	$Username.editable = false
	
	await multiplayer.connected_to_server
	var uname = $Username.text
	Network.set_username.rpc_id(1, uname if uname else "Player%d" % multiplayer.get_unique_id())


func _on_cancel_pressed() -> void:
	multiplayer.multiplayer_peer = null
	$Waiting.visible = false
	$Start.visible = true
	$Username.editable = true
