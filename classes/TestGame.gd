extends Control

func _ready() -> void:
	var numPlayers: int = 1
	$GameVLayout.init(numPlayers, 16, 10, 20)
	$Gameplay.init($GameVLayout._board, numPlayers)
	
	# Connect gameplay changes to the GUI
	$Gameplay.connect("hold_shape_changed", $GameVLayout, "handle_hold_shape_changed")
	$Gameplay.connect("next_shapes_changed", $GameVLayout, "handle_next_shapes_changed")
	$Gameplay.connect("lines_cleared_changed", $GameVLayout, "handle_lines_cleared_changed")
	$Gameplay.connect("score_changed", $GameVLayout, "handle_score_changed")
	$Gameplay.connect("level_changed", $GameVLayout, "handle_level_changed")
	$Gameplay.connect("new_game", $GameVLayout, "handle_new_game")
	$Gameplay.connect(
		"updated_ghost_shape",
		$GameVLayout/HBoxContainer/GameBoard/BoardContainer/EffectsBoard,
		"handle_updated_ghost_shape"
	)
	
	# Hook up the controls to the gameplay functions
	$GameplayControls.init(numPlayers, $Gameplay)
	
	$Gameplay.newGame()
