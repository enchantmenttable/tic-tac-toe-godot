extends Node

onready var o_texture = preload("res://new_assets/o.png")

var human_score = 0
var comp_score = 0
var win_line = []
var comp_turn = false


func _ready():
	$Menu/Score.hide()
	$Menu/Draw.hide()


var COMP = +1
var HUMAN = -1
var board = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]

var moves = {
	1: [0, 0],
	2: [0, 1],
	3: [0, 2],
	4: [1, 0],
	5: [1, 1],
	6: [1, 2],
	7: [2, 0],
	8: [2, 1],
	9: [2, 2]
}


func update_board_array():
	var poses = $Grid.get_children()
	for pos in poses:
		if pos.get_node("x_o").texture != null:
			if pos.get_node("x_o").texture.get_path() == "res://new_assets/x.png":
				var move = moves[int(pos.name.substr(3))]
				board[move[0]][move[1]] = HUMAN


func update_grid_render(x, y, player):
	var select_option
	var texture
	match player:
		COMP:
			select_option = true
			texture = o_texture
		0:
			select_option = false
			texture = null
	for i in range(1, 10):
		if moves[i] == [x, y]:
			get_node("Grid/POS" + str(i) + "/x_o").set_texture(texture)
			get_node("Grid/POS" + str(i)).spr_selected = select_option


func wins(state, player):
	var win_states = [
		[state[0][0], state[0][1], state[0][2]],
		[state[1][0], state[1][1], state[1][2]],
		[state[2][0], state[2][1], state[2][2]],
		[state[0][0], state[1][0], state[2][0]],
		[state[0][1], state[1][1], state[2][1]],
		[state[0][2], state[1][2], state[2][2]],
		[state[0][2], state[1][1], state[2][0]],
		[state[2][2], state[1][1], state[0][0]]
	]
	var win_line_indices = [
		[[0, 0], [0, 1], [0, 2]],
		[[1, 0], [1, 1], [1, 2]],
		[[2, 0], [2, 1], [2, 2]],
		[[0, 0], [1, 0], [2, 0]],
		[[0, 1], [1, 1], [2, 1]],
		[[0, 2], [1, 2], [2, 2]],
		[[0, 2], [1, 1], [2, 0]],
		[[2, 2], [1, 1], [0, 0]]
	]
	if [player, player, player] in win_states:
		win_line = win_line_indices[win_states.find([player, player, player])]
		return true
	else:
		return false


func evaluate(state):
	var score
	if wins(state, COMP):
		score = +1
	elif wins(state, HUMAN):
		score = -1
	else:
		score = 0

	return score


func enumerate(array):
	var i = 0
	var enum_arr = []
	for cell in array:
		enum_arr.append([i, cell])
		i += 1
	return enum_arr


func empty_cells(state):
	var cells = []

	for x_row in enumerate(state):
		for y_cell in enumerate(x_row[1]):
			if y_cell[1] == 0:
				cells.append([x_row[0], y_cell[0]])
	return cells


func valid_move(x, y):
	if [x, y] in empty_cells(board):
		return true
	else:
		return false


func set_move(x, y, player):
	if valid_move(x, y):
		board[x][y] = player
		return true
	else:
		return false


func game_over(state):
	if evaluate(state) != 0 or (evaluate(state) == 0 and len(empty_cells(state)) == 0):
		return true
	else:
		return false


func minimax(state, depth, player, alpha, beta):
	var best = []
	var score = []
	if player == COMP:
		best = [-1, -1, -1000]
	else:
		best = [-1, -1, +1000]

	if depth == 0 or game_over(state):
		score = evaluate(state)
		return [-1, -1, score]

	for cell in empty_cells(state):
		var x = cell[0]
		var y = cell[1]
		state[x][y] = player
		score = minimax(state, depth - 1, -player, alpha, beta)
		state[x][y] = 0
		score[0] = x
		score[1] = y

		if player == COMP:
			if score[2] > best[2]:
				best = score
				alpha = max(alpha, best[2])
				if alpha > beta:
					break

		else:
			if score[2] < best[2]:
				best = score
				beta = min(beta, best[2])
				if beta <= alpha:
					break
	return best


func ai_turn():
	var alpha = -1000
	var beta = +1000
	var x = -1
	var y = -1
	var move = []
	var depth = len(empty_cells(board))
	if depth == 0 or game_over(board):
		return

	if depth == 9:
		x = randi() % 3
		y = randi() % 3
	else:
		move = minimax(board, depth, COMP, alpha, beta)
		x = move[0]
		y = move[1]

	set_move(x, y, COMP)
	update_grid_render(x, y, COMP)
	comp_turn = false


func score_board(player):
	if player == HUMAN:
		human_score += 1
	elif player == COMP:
		comp_score += 1
	$Menu/Score/HumanScore.text = str(human_score)
	$Menu/Score/AIScore.text = str(comp_score)
	$Menu/Score.show()


func update():
	update_board_array()
	if comp_turn:
		yield(get_tree().create_timer(0.3), "timeout")
		ai_turn()
	if wins(board, HUMAN):
		score_board(HUMAN)
		yield(get_tree().create_timer(1.5), "timeout")
		clear_line(win_line)

	elif wins(board, COMP):
		score_board(COMP)
		yield(get_tree().create_timer(1.5), "timeout")
		clear_line(win_line)

	elif len(empty_cells(board)) == 0:
		$Menu/Draw.show()
		yield(get_tree().create_timer(1.5), "timeout")
		clear_all()

	$Menu/Draw.hide()
	$Menu/Score.hide()

	if comp_turn:
		yield(get_tree().create_timer(0.3), "timeout")
		ai_turn()


func clear_all():
	for x in range(3):
		for y in range(3):
			board[x][y] = 0
			update_grid_render(x, y, 0)


func clear_line(line):
	for coordinate in line:
		board[coordinate[0]][coordinate[1]] = 0
		update_grid_render(coordinate[0], coordinate[1], 0)
