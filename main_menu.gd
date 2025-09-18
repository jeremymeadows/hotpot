extends Control


func _on_host_pressed() -> void:
	get_tree().change_scene_to_file('res://host_game.tscn')


func _on_join_pressed() -> void:
	get_tree().change_scene_to_file('res://player_client.tscn')


func _on_text_edit_text_changed() -> void:
	Network.username = $TextEdit.text
