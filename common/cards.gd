extends Node

const _CARD_SIZE = Vector2(204, 300)

const CARDS = {
	"noodles": [
		"macaroni",
		"ramen",
		"udon",
	],
	"seafood": [
		"fish",
		"crab",
		"prawn",
	],
	"greens": [
		"bokchoy",
		"cabbage",
		"onion",
	],
	"spices": [
		"garlic",
		"heatroot",
		"clove",
	],
	"veggies": [
		"corn",
		"potato",
		"carrot",
	],
	"meat": [
		"prosciutto",
		"steak",
		"lardons",
	],
	"mushrooms": [
		"morel",
		"brightshroom",
		"enoki",
	],
	"carbs": [
		"tofu",
		"ricecake",
		"gyoza",
	],
}


func card_names():
	var cards = []
	for food in CARDS.values():
		cards += food
	return cards


func get_type_of(card):
	for type in CARDS:
		if card in CARDS[type]:
			return type
	return null


func get_deck():
	var cards = card_names()
	return cards + cards + cards + cards


func position_of(card):
	var i = card_names().find(card)
	if i > -1:
		return Vector2(i % 3 * _CARD_SIZE.x, i / 3 * _CARD_SIZE.y)
	else:
		return null


func check_complete(hand):
	var cards = {}
	var score = 0
	for card in hand:
		var type = get_type_of(card)
		if type not in cards:
			cards[type] = []
		cards[type] += [card]
	
	if len(cards) > 3:
		return null
	
	for type in cards:
		if len(cards[type]) == 3:
			if cards[type][0] == cards[type][1] and cards[type][1] == cards[type][2]:
				score += 3
			elif cards[type][0] != cards[type][1] and cards[type][1] != cards[type][2] and cards[type][0] != cards[type][2]:
				score += 1
			else:
				return null
		elif len(cards[type]) == 6:
			pass
		elif len(cards[type]) == 9:
			pass
		else:
			return null
	return score

func sort(a, b) -> bool:
	var cards = card_names()
	return cards.find(a) < cards.find(b)
