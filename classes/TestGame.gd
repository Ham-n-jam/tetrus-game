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

func _on_LeftButton_button_down() -> void:
	$Gameplay.attemptMoveLeft(1)
#	for player in _players:
#		$Gameplay.attemptMoveLeft(player)

	
func _on_RightButton_button_down() -> void:
	$Gameplay.attemptMoveRight(1)
#	for player in _players:
#		$Gameplay.attemptMoveRight(player)


func _on_GravityButton_button_down() -> void:
	$Gameplay.attemptGravity(1)
#	for player in _players:
#		$Gameplay.attemptGravity(player)
#	$Gameplay._board.printBoardState()
#	print("\n")


func _on_RotLButton_button_down() -> void:
	$Gameplay.attemptRotateLeft(1)
#	for player in _players:
#		$Gameplay.attemptRotateLeft(player)


func _on_RotRButton_button_down() -> void:
	$Gameplay.attemptRotateRight(1)
#	for player in _players:
#		$Gameplay.attemptRotateRight(player)


func _on_HardDButton_button_down() -> void:
	$Gameplay.attemptHardDrop(1)


func _input(ev):
	if ev is InputEventKey and not ev.echo:
		if (Input.is_key_pressed(KEY_S)):
			$Gameplay.attemptGravity(1)
		if (Input.is_key_pressed(KEY_W)):
			$Gameplay.attemptHardDrop(1)
		if (Input.is_key_pressed(KEY_A)):
			$Gameplay.attemptMoveLeft(1)
		if (Input.is_key_pressed(KEY_D)):
			$Gameplay.attemptMoveRight(1)
		if (Input.is_key_pressed(KEY_Q)):
			$Gameplay.attemptRotateLeft(1)
		if (Input.is_key_pressed(KEY_E)):
			$Gameplay.attemptRotateRight(1)
		if (Input.is_key_pressed(KEY_X)):
			$Gameplay.attemptHold(1)

		if (_players.size() > 1):
			if (Input.is_key_pressed(KEY_K)):
				$Gameplay.attemptGravity(2)
			if (Input.is_key_pressed(KEY_I)):
				$Gameplay.attemptHardDrop(2)
			if (Input.is_key_pressed(KEY_J)):
				$Gameplay.attemptMoveLeft(2)
			if (Input.is_key_pressed(KEY_L)):
				$Gameplay.attemptMoveRight(2)
			if (Input.is_key_pressed(KEY_U)):
				$Gameplay.attemptRotateLeft(2)
			if (Input.is_key_pressed(KEY_O)):
				$Gameplay.attemptRotateRight(2)
			if (Input.is_key_pressed(KEY_M)):
				$Gameplay.attemptHold(2)
