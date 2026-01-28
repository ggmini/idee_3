extends Node


enum sides {
	PLAYER,
	AI
}

var active_side: sides = sides.PLAYER

@onready var game_manager: GameManager = get_tree().get_child(-1)


func end_turn():
	active_side = (active_side + 1) % sides.size()
	game_manager.active_entity = null
	refresh_ranges()


func refresh_ranges():
	for child in game_manager.get_children():
		if child is Entity:
			child.range_left = child.entity_range
