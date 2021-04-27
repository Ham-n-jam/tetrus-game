extends Control

class_name EffectBlock

var _rng = RandomNumberGenerator.new()

func setColour(colour: Color):
	$AnimatedSprite.modulate = colour


func playAnimation(animation: String):
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(animation)


func doExplosion():
	setColour(Color.white)
	
	# Add a bit of randomness to the explosion time and animation
	_rng.randomize()
	$Timer.wait_time = _rng.randf_range(0.0, 0.25)
	$Timer.start()
	yield($Timer, "timeout")
	playAnimation("16explosion%d" % _rng.randi_range(1, 3))
