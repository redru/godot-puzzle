extends Node2D

var pieces = []
var merged_pieces = {}
var connections_joined_count = 0
var total_connections: int

func _ready() -> void:
	pieces = get_children_in_group(get_children(), "pieces")
	
	for piece in pieces:
		piece.connect("pieces_connected", _on_pieces_connected)
		piece.connect("piece_moved", _on_piece_moved)
		total_connections += get_children_in_group(piece.get_children(), "connections").size()
	
	print(str(total_connections) + " total connections")

func _process(delta: float) -> void:
	pass

func get_children_in_group(array: Array, group_name: String) -> Array:
	var group_children = []
	# Get all children of this node
	for child in array:
		# Check if the child is in the specified group
		if child.is_in_group(group_name):
			group_children.append(child)
	
	return group_children

func _on_pieces_connected(first: Node2D, second: Node2D, first_connection: Node2D, second_connection: Node2D) -> void:
	connections_joined_count += 2
	
	if merged_pieces.has(first):
		merged_pieces[first].append(second)
	else:
		merged_pieces[first] = [second]
	
	if merged_pieces.has(second):
		merged_pieces[second].append(first)
	else:
		merged_pieces[second] = [first]
	
	var adjustment = second_connection.global_position - first_connection.global_position
	first.global_position += adjustment
	
func _on_piece_moved(piece: Node2D, relative: Vector2) -> void:
	if merged_pieces.has(piece):
		var already_moved = {}
		already_moved[piece] = true
		move_connected_pieces(piece, merged_pieces[piece], already_moved, relative)
	
func move_connected_pieces(piece: Node2D, child_pieces: Array, already_moved: Dictionary, relative: Vector2) -> void:
		# Move the piece
		if !already_moved.has(piece):
			piece.position += relative
			already_moved[piece] = true
			
		# Move the child pieces if not already moved
		for child_piece in child_pieces:
			if !already_moved.has(child_piece):
				move_connected_pieces(child_piece, merged_pieces[child_piece], already_moved, relative)
	
