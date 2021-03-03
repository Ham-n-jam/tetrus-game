extends Node

enum _ControlTypeEnum {GAMEPLAY, PAUSE_MENU}

var _gameplay


func init(gameplay: Gameplay):
	_gameplay = gameplay


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
