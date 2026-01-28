class_name GameManager
extends Node2D


@export var map: Map

@export_category("UI")
@export var entity_name: RichTextLabel
@export var entity_range: RichTextLabel

var active_entity: Entity


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in self.get_children():
		if child is Entity:
			child.selected.connect(_on_entity_selected)


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
	entity_range.text = str(entity.range_left)


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


func get_entity_at_pos(pos: Vector2i):
	for child in get_children():
		if child is Entity:
			if child.map_position == pos:
				return child
	
	return null
