extends Node2D

@export var texture: Texture2D
@export var region: Rect2

@onready var sprite: Sprite2D = $Sprite2D

signal piece_moved(piece: Node2D, relative: Vector2)
signal pieces_connected(first: Node2D, second: Node2D, first_connection: Node2D, second_connection: Node2D)

var is_dragging: bool = false
var connections: Array = []

func _ready() -> void:
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	
	connections = get_children_in_group("connections")

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
		piece_moved.emit(self, event.relative)

func start_dragging() -> void:
	if !is_dragging:
		sprite.z_index = 100
		is_dragging = true

func stop_dragging() -> void:
	if is_dragging:
		sprite.z_index = 0
		is_dragging = false
		check_connections()
		
func get_children_in_group(group_name: String) -> Array:
	var group_children = []
	# Get all children of this node
	for child in get_children():
		# Check if the child is in the specified group
		if child.is_in_group(group_name):
			group_children.append(child)
	
	return group_children
	
func check_connections() -> void:
	for connection: Node2D in connections:
		if connection.joined:
			continue
		
		var this_id: int = connection.join_id
		var connection_area: Area2D = connection.get_child(0)
		
		for other_area: Area2D in connection_area.get_overlapping_areas():
			var other_connection: Node2D = other_area.get_parent()
			
			if other_connection.joined:
				continue
			
			var other_join_id: int = other_connection.join_id
			
			if this_id == other_join_id:
				connection.joined = true
				other_connection.joined = true
				
				pieces_connected.emit(self, other_connection.get_parent(), connection, other_connection)
