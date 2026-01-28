extends Entity



func _input(event: InputEvent) -> void:
	if TurnManager.active_side != TurnManager.sides.AI:
		return
	
	super(event)
