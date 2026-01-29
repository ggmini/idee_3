class_name GameManager
extends Node2D


@export var map: Map

@export_category("UI")
@export var entity_name: RichTextLabel
@export var entity_range: RichTextLabel
var range_display: Array[Sprite2D]
var marker_scene = load("res://movement_marker.tscn")


var active_entity: Entity
var entities: Array[Entity]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in self.get_children():
		if child is Entity:
			entities.append(child)
			child.selected.connect(_on_entity_selected)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if active_entity:
			active_entity = null
			clear_range_display()
			refresh_ui()
		for e in entities:
			var click_mouse_position = get_global_mouse_position()
			var click_map_position = map.local_to_map(click_mouse_position)
			e.check_for_selection(click_map_position)
			if active_entity:
				get_range_display(click_map_position)
	
	if event.is_action_pressed("right_click"):
		print("move")
		if not active_entity:
			print("fail")
			return
		var click_position = get_global_mouse_position()
		var selected_cell = map.local_to_map(click_position)
		await active_entity.move_to_cell(selected_cell)
		refresh_ui()
		if (active_entity.range_left > 0):
			get_range_display(selected_cell)
		else:
			clear_range_display()
	elif event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_MASK_RIGHT:
			entity_attack()


func _on_entity_selected(entity: Entity):
	self.active_entity = entity
	refresh_ui()

func refresh_ui():
	if not active_entity:
		entity_name.text = "N/A"
		entity_range.text = "N/A"
		return
	entity_name.text = active_entity.entity_name
	entity_range.text = str(active_entity.range_left)

func clear_range_display() -> void:
	for marker in range_display:
		marker.queue_free()
	range_display.clear()

func get_range_display(pos: Vector2i) -> void:
	clear_range_display()
	print(pos)
	
	var cells = map.get_used_cells()
	for cell in cells:
		print(cell)
		var path: PackedVector2Array = map.get_map_path(pos, cell)
		if cell.x == pos.x and cell.y == pos.y:
			continue
		if not path:
			continue
		if path.size() > 0:
			path.remove_at(0)
		if path.size() < active_entity.range_left+1:
			#create display fragment
			var marker = marker_scene.instantiate()
			add_child(marker)
			range_display.append(marker)
			marker.position = map.map_to_local(cell)

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
