extends TextureButton

@export
var card: String:
	set(v):
		_on_card_change(v)

var textures = preload('res://assets/cards.tres')

func _on_card_change(card):
	if card in Cards.card_names():
		texture_normal = textures.duplicate()
		texture_normal.region.position = Cards.position_of(card)
	#elif card == "?":
	else:
		texture_normal = ImageTexture.create_from_image(Image.load_from_file("res://assets/card_back.svg"))
	#else:
		#visible = false
