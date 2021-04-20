extends Control

var _players: Array = []

func _ready() -> void:
	var numPlayers: int = 2
	$GameVLayout.init("P1", 16, 14, 20)
	$Gameplay.init($GameVLayout._board, numPlayers)
	
	# Connect gameplay changes to the GUI
	$Gameplay.connect("hold_shape_changed", $GameVLayout, "handle_hold_shape_changed")
	$Gameplay.connect("next_shapes_changed", $GameVLayout, "handle_next_shapes_changed")
	$Gameplay.connect("lines_cleared_changed", $GameVLayout, "handle_lines_cleared_changed")
	$Gameplay.connect("score_changed", $GameVLayout, "handle_score_changed")
	$Gameplay.connect("new_game", $GameVLayout, "handle_new_game")
	
	for i in range(1, numPlayers + 1):
		_players.append(i)
	
	$Gameplay.newGame()


func _input(ev):
	if ev is InputEventKey and not ev.echo:
		if (ev.pressed and ev.scancode == KEY_S):
			$Gameplay.attemptGravity(1)
		if (ev.pressed and ev.scancode == KEY_W):
			$Gameplay.attemptHardDrop(1)
		if (ev.pressed and ev.scancode == KEY_A):
			$Gameplay.attemptMoveLeft(1)
		if (ev.pressed and ev.scancode == KEY_D):
			$Gameplay.attemptMoveRight(1)
		if (ev.pressed and ev.scancode == KEY_Q):
			$Gameplay.attemptRotateLeft(1)
		if (ev.pressed and ev.scancode == KEY_E):
			$Gameplay.attemptRotateRight(1)
		if (ev.pressed and ev.scancode == KEY_X):
			$Gameplay.attemptHold(1)

		if (_players.size() > 1):
			if (ev.pressed and ev.scancode == KEY_K):
				$Gameplay.attemptGravity(2)
			if (ev.pressed and ev.scancode == KEY_I):
				$Gameplay.attemptHardDrop(2)
			if (ev.pressed and ev.scancode == KEY_J):
				$Gameplay.attemptMoveLeft(2)
			if (ev.pressed and ev.scancode == KEY_L):
				$Gameplay.attemptMoveRight(2)
			if (ev.pressed and ev.scancode == KEY_U):
				$Gameplay.attemptRotateLeft(2)
			if (ev.pressed and ev.scancode == KEY_O):
				$Gameplay.attemptRotateRight(2)
			if (ev.pressed and ev.scancode == KEY_M):
				$Gameplay.attemptHold(2)

