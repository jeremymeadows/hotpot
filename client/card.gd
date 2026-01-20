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


#func add_margin(size: int, target: Texture) -> void:
	##var target = texture_normal
	#
	#if not target or not target.texture:
		#return
#
	#var original_texture: Texture2D = target.texture
	#var image := original_texture.get_image()
	#
	## Calculate new dimensions
	#var new_width := image.get_width() + (2 * size)
	#var new_height := image.get_height() + (2 * size)
	#
	## Create new image with transparency
	#var new_image := Image.create(new_width, new_height, false, Image.FORMAT_RGBA8)
	#new_image.fill(Color(0, 0, 0, 0))  # Fill with transparent color
#
	## Copy original image to new position with offset
	#new_image.blit_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), Vector2i(size, size))
#
	## Create and assign new texture
	#var new_texture := ImageTexture.create_from_image(new_image)
	#print(target.texture)
	#target.texture = new_texture
	#print(target.texture)


func _on_mouse_entered() -> void:
	#(material as ShaderMaterial).set_shader_parameter("line_color", Color(1, 1, 1, 1))
	if not disabled and card != "none":
		$Outline.visible = true
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_mouse_exited() -> void:
	#(material as ShaderMaterial).set_shader_parameter("line_color", Color(0, 0, 0, 0))
	$Outline.visible = false
