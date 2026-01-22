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


func winning_hand(hand: Array):
	hand.sort_custom(sort)
	var sets = 0
	
	var i = 0
	while i <= len(hand) - 3:
		if hand.slice(i, i + 3).all(func(e): return e == hand[i]):
			sets += 1
			for __ in range(3):
				hand.remove_at(i)
			i = -1
		elif hand.slice(i, i + 3).all(func(e): return get_type_of(e) == get_type_of(hand[i])):
			if hand[i] != hand[i + 1] and hand[i] != hand[i + 2] and hand[i + 1] != hand[i + 2]:
				sets += 1
				for __ in range(3):
					hand.remove_at(i)
				i = -1
		i += 1
	return sets == 3

func sort(a, b) -> bool:
	var cards = card_names()
	return cards.find(a) < cards.find(b)
