extends Control


func doCountdown() -> void:
	$AnimatedSprite.visible = true
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("countdown")
	
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.visible = false
