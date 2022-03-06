extends Control


func doGameOver(score: int, lines: int) -> void:
	$GameOverMenuController/AnimatedSprite.visible = true
	$GameOverMenuController/AnimatedSprite.frame = 0
	$GameOverMenuController/AnimatedSprite.play("gameOver")
	
	yield($GameOverMenuController/AnimatedSprite, "animation_finished")
	
	$GameOverMenuController/Score.visible = true
	$GameOverMenuController/ScoreNum.text = String(score)
	$GameOverMenuController/ScoreNum.visible = true
	
	$GameOverMenuController/Lines.visible = true
	$GameOverMenuController/LinesNum.text = String(lines)
	$GameOverMenuController/LinesNum.visible = true
	
	$GameOverMenuController/PlayAgain.visible = true
	$GameOverMenuController/BackToMainMenu.visible = true
	$GameOverMenuController/Description.visible = true
	
	$GameOverMenuController.startUpMenu("vertical")


func closePanel() -> void:
		$GameOverMenuController/AnimatedSprite.visible = false
		$GameOverMenuController/Score.visible = false
		$GameOverMenuController/ScoreNum.visible = false
		$GameOverMenuController/Lines.visible = false
		$GameOverMenuController/LinesNum.visible = false
		$GameOverMenuController/PlayAgain.visible = false
		$GameOverMenuController/BackToMainMenu.visible = false
		$GameOverMenuController/Description.visible = false
		
		yield($GameOverMenuController.shutDownMenu(), "completed")