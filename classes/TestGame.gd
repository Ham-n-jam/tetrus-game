extends Control

var _players: Array = []

func _ready() -> void:
	var numPlayers: int = 1
	$GameVLayout.init("P1", 16, 10, 20)
	$Gameplay.init($GameVLayout._board, numPlayers)
	$Gameplay.newGame()
	for i in range(1, numPlayers + 1):
		_players.append(i)
	
	$Gameplay.connect("hold_shape_changed", $GameVLayout, "handle_hold_shape_changed")


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
