extends Camera2D

@export var max_x: int
@export var max_y: int
@export var min_x: int
@export var min_y: int

@export var moveSpeed: float

func _process(_delta: float) -> void:
	var camera_movement = Vector2(0, 0) 
	if Input.is_action_pressed("ui_right"):
		camera_movement.x += 1
	if Input.is_action_pressed("ui_left"):
		camera_movement.x -= 1
	if Input.is_action_pressed("ui_up"):
		camera_movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		camera_movement.y += 1
	move(camera_movement, _delta)

func move(direction: Vector2, delta: float):
	self.position += direction * moveSpeed * delta * 100
