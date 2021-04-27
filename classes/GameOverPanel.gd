extends Control


func doGameOver(score: int, lines: int) -> void:
	$Control/AnimatedSprite.visible = true
	$Control/AnimatedSprite.frame = 0
	$Control/AnimatedSprite.play("gameOver")
	
	yield($Control/AnimatedSprite, "animation_finished")
	
	$Control/Score.visible = true
	$Control/ScoreNum.text = String(score)
	$Control/ScoreNum.visible = true
	
	$Control/Lines.visible = true
	$Control/LinesNum.text = String(lines)
	$Control/LinesNum.visible = true