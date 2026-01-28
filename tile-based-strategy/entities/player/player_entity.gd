class_name PlayerEntity
extends Entity



func _input(event: InputEvent) -> void:
	if TurnManager.active_side != TurnManager.sides.PLAYER:
		return
	
	super(event)
