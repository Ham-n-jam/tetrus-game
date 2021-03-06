extends Control

class_name EffectBlock

var _rng = RandomNumberGenerator.new()


func playAnimation(animation: String, colour: Color=Color.white):
	$AnimatedSprite.modulate = colour
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(animation)


func doExplosion():
	# Add a bit of randomness to the explosion time and animation
	_rng.randomize()
	$Timer.wait_time = _rng.randf_range(0.0, 0.25)
	$Timer.start()
	yield($Timer, "timeout")
	playAnimation("16explosion%d" % _rng.randi_range(1, 3))


func doPause():
	$Timer.stop()
	playAnimation("16fadeInBlack")


func doUnpause():
	$Timer.stop()
	$AnimatedSprite.play("16fadeInBlack", true)
