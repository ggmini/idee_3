class_name GameManager
extends Node2D


@export var map: Map

@export_category("UI")
@export var entity_name: RichTextLabel
@export var entity_range: RichTextLabel

var active_entity: Entity

@onready var end_turn_button: Button = $CanvasLayer/Control/EndTurnButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	for child in self.get_children():
		if child is Entity:
			child.selected.connect(_on_entity_selected)
			child.range_left_changed.connect(_on_range_left_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if not active_entity:
			return
		var click_position = get_global_mouse_position()
		var seleted_cell = map.local_to_map(click_position)
		active_entity.move_to_cell(seleted_cell)
	elif event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_MASK_RIGHT:
			entity_attack()


func _on_entity_selected(entity: Entity):
	self.active_entity = entity
	entity_name.text = entity.entity_name
	entity_range.text = str(entity.entity_range)


func entity_attack():
	if not active_entity:
		print("no unit selected")
		return
	
	var map_pos := active_entity.map_position
	var target_pos := map.local_to_map(get_global_mouse_position())
	var diff: int = abs(map_pos.x - target_pos.x) + abs(map_pos.y - target_pos.y)
	
	if diff > active_entity.attack_range:
		print("not enough range")
		return
	
	var target_entity = get_entity_at_pos(target_pos)
	if not target_entity:
		print("no entity at target")
		return
	
	active_entity.attack(target_entity)
	active_entity.add_line_to_log(active_entity.name + " is attacking " + target_entity.name + " for " + str(active_entity.attack_val))
	TurnManager.end_turn()



func get_entity_at_pos(pos: Vector2i):
	for child in get_children():
		if child is Entity:
			if child.map_position == pos:
				return child
	
	return null


func _on_range_left_changed(entity: Entity, new_val: int):
	if entity == active_entity:
		entity_range.text = str(new_val)


func _on_end_turn_button_pressed():
	if TurnManager.active_side == TurnManager.sides.PLAYER:
		TurnManager.end_turn()
