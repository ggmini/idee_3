class_name EnemyEntity
extends Entity


signal movement_finished
signal turn_finished

func _input(event: InputEvent) -> void:
	if TurnManager.active_side != TurnManager.sides.AI:
		return
	
	super(event)


func play_turn():
	var a_star: AStar2D = map.a_star
	var target: PlayerEntity = _get_closest_enemy()
	
	if attack_check(target.map_position):
		add_line_to_log(name + " is attacking " + target.name + " for " + str(attack_val))
		attack(target)
		
		return
	
	var target_cell: Vector2i = _get_closest_unblocked_neighbor_cell(target.map_position)
	
	
	var enemies: Array = get_tree().get_nodes_in_group("EnemyEntity")
	var players: Array = get_tree().get_nodes_in_group("PlayerEntity")
	var obstacles = enemies + players
	obstacles.erase(self)
	obstacles = obstacles.map(func(obs: Entity): return obs.map_position)
	for obstacle in obstacles:
		var id: int = map.map_dict[obstacle]
		a_star.set_point_disabled(id)
	
	
	var path: Array = a_star.get_point_path(map.map_dict[map_position], map.map_dict[target_cell])
	path.remove_at(0)
	
	for obstacle in obstacles:
		var id: int = map.map_dict[obstacle]
		a_star.set_point_disabled(id, false)
	
	await _move_toward_player(path)
	
	if attack_check(target.map_position):
		add_line_to_log(name + " is attacking " + target.name + " for " + str(attack_val))
	
		attack(target)
	
	return turn_finished


func attack_check(target_cell: Vector2i) -> bool:
	return target_cell in _get_unblocked_neighbor_cells(self.map_position, false)


func _get_closest_enemy():
	var candidates: Array = get_tree().get_nodes_in_group("PlayerEntity")
	var distances: Array = candidates.map(func(enemy: PlayerEntity): return (enemy.map_position - self.map_position).length())
	var target_idx: int = distances.find(distances.min())
	
	return candidates[target_idx]


func _get_unblocked_neighbor_cells(cell: Vector2i, count_enemies: bool = true):
	var game_manager: GameManager = get_tree().root.get_child(-1)
	var neighbors: Array = map.get_surrounding_cells(cell)
	
	if count_enemies:
		neighbors = neighbors.filter(func(neighbor): return game_manager.get_entity_at_pos(neighbor) == null)
	
	neighbors = neighbors.filter(func(neighbor): return map.get_cell_source_id(neighbor) != -1)
	
	return neighbors


func _get_closest_unblocked_neighbor_cell(cell: Vector2i):
	var neighbors: Array = _get_unblocked_neighbor_cells(cell)
	var distances: Array = neighbors.map(func(neighbor: Vector2i): return (cell - neighbor).length())
	var target_idx: int = distances.find(distances.min())
	
	return neighbors[target_idx]


func _move_toward_player(path: Array) -> Signal:
	var i: int = 0
	while self.range_left > 0 and i < path.size():
		var point: Vector2i = path[i]
		await _move_to_position(point)
		map_position = map.local_to_map(self.position)
		self.range_left -= 1
		i += 1
	
	return movement_finished
