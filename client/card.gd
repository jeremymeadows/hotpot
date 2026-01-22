extends TextureButton

@export
var card: String:
	set(v):
		card = v
		_on_card_change(v)

static var textures = preload('res://assets/cards.tres')


func _ready() -> void:
	$AnimationPlayer.play("RESET")


func _on_card_change(new_card):
	$AnimationPlayer.play("flip")
	await $AnimationPlayer.animation_finished
	
	if new_card in Cards.card_names():
		texture_normal = textures.duplicate()
		texture_normal.region.position = Cards.position_of(new_card)
	elif new_card == "none":
		texture_normal = Texture.new()
		$Outline.visible = false
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		var tex = ImageTexture.create_from_image(Image.load_from_file("res://assets/card_back.svg"))
		texture_normal = tex
	$AnimationPlayer.play_backwards("flip")


func _on_mouse_entered() -> void:
	if not disabled and card != "none":
		$Outline.visible = true
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_mouse_exited() -> void:
	$Outline.visible = false
