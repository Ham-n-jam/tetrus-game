extends Control

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
	
	# Hook up the controls to the gameplay functions
	$GameplayControls.init(numPlayers, $Gameplay)
	
	$Gameplay.newGame()
