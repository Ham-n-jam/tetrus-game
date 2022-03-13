extends OuterMenuInputHandler


func doGameOver(score: int, lines: int) -> void:
	$OuterMenu/AnimatedSprite.visible = true
	$OuterMenu/AnimatedSprite.frame = 0
	$OuterMenu/AnimatedSprite.play("gameOver")
	
	yield($OuterMenu/AnimatedSprite, "animation_finished")
	
	$OuterMenu/Score.visible = true
	$OuterMenu/ScoreNum.text = String(score)
	$OuterMenu/ScoreNum.visible = true
	
	$OuterMenu/Lines.visible = true
	$OuterMenu/LinesNum.text = String(lines)
	$OuterMenu/LinesNum.visible = true
	
	$OuterMenu/PlayAgain.visible = true
	$OuterMenu/BackToMainMenu.visible = true
	$OuterMenu/Description.visible = true
	
	$OuterMenu.startUpMenu("vertical")


func closePanel() -> void:
		$OuterMenu/AnimatedSprite.visible = false
		$OuterMenu/Score.visible = false
		$OuterMenu/ScoreNum.visible = false
		$OuterMenu/Lines.visible = false
		$OuterMenu/LinesNum.visible = false
		$OuterMenu/PlayAgain.visible = false
		$OuterMenu/BackToMainMenu.visible = false
		$OuterMenu/Description.visible = false
		
		MenuControlsGuide.fadeOut()
		yield($OuterMenu.shutDownMenu(), "completed")
		
