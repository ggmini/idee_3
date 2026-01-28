extends Node


enum sides {
	PLAYER,
	AI
}

var active_side: sides = sides.PLAYER

@onready var game_manager: GameManager = get_tree().root.get_child(-1)


func end_turn():
	active_side = (active_side + 1) % sides.size()
	game_manager.active_entity = null
	refresh_ranges()
	if active_side == sides.AI:
		_enemy_turn()


func refresh_ranges():
	for child in game_manager.get_children():
		if child is Entity:
			child.range_left = child.entity_range


func _enemy_turn():
	print("enemy turn starting")
	var enemies: Array = get_tree().get_nodes_in_group("EnemyEntity")
	for enemy: EnemyEntity in enemies:
		await enemy.play_turn()
	
	print("enemy turn finished")
	end_turn()
