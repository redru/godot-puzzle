extends Node2D

@export var texture: Texture2D
@export var region: Rect2

@onready var sprite: Sprite2D = $Sprite2D

var is_dragging: bool = false

func _ready() -> void:
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		stop_dragging()

func _on_dragging_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		handle_mouse_button_event(event)
		
	if event is InputEventMouseMotion:
		handle_dragging(event)

func handle_mouse_button_event(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_dragging()
		elif event.is_released():
			stop_dragging()

func handle_dragging(event: InputEventMouseMotion) -> void:
	if is_dragging:
		position += event.relative

func start_dragging() -> void:
	if !is_dragging:
		sprite.z_index = 100
		is_dragging = true

func stop_dragging() -> void:
	if is_dragging:
		sprite.z_index = 0
		is_dragging = false
