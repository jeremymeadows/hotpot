extends Control

static var arrow = load('res://assets/cursors/cursor_arrow.png')
static var pointer = load('res://assets/cursors/cursor_pointer.png')
static var beam = pointer

var countdown_time:
	set(time):
		countdown_time = time
		$Waiting/Cancel.text = "Cancel (%d)" % time


func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(pointer, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)


func _on_quick_play_pressed() -> void:
	print("Client connecting to `%s`" % Network.SOCKET)
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client(Network.SOCKET)
	multiplayer.multiplayer_peer = peer
	
	countdown_time = 10
	$Start.visible = false
	$Waiting.visible = true
	$Username.editable = false
	
	await multiplayer.connected_to_server
	var uname = $Username.text
	Network.set_username.rpc_id(1, uname if uname else "Player%d" % multiplayer.get_unique_id())
	_start_game_countdown()


func _on_cancel_pressed() -> void:
	multiplayer.multiplayer_peer = null
	$Waiting.visible = false
	$Start.visible = true
	$Username.editable = true
	$Waiting/Timer.stop()
	$Waiting/Timer.timeout.disconnect(_timer_countdown)


func _on_host_pressed() -> void:
	get_tree().change_scene_to_file('res://host_game.tscn')


func _on_join_pressed() -> void:
	get_tree().change_scene_to_file('res://player_client.tscn')


func _on_rules_pressed() -> void:
	$Rules.visible = true


func _on_close_pressed() -> void:
	$Rules.visible = false


func _start_game_countdown() -> void:
	$Waiting/Timer.timeout.connect(_timer_countdown)
	$Waiting/Timer.start(1)


func _timer_countdown():
	countdown_time -= 1
	if countdown_time > 0:
		$Waiting/Timer.start(1)
