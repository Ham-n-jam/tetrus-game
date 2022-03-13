extends MenuOption


export(String, "Master", "BGM", "SFX") var audioChannel: String = "Master"
var currentVolume: int = 7 setget setCurrentVolume


func _ready():
	
	description = "Set the " + audioChannel + " volume."
	$VolLabel.text = audioChannel + " Volume"
	hideArrows()


func loadVolume() -> void:
	self.currentVolume = round(20 * db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(audioChannel))))


func onLeft() -> void:
	decreaseVol()


func onRight() -> void:
	increaseVol()


func onHover() -> void:
	showArrows()


func onUnhover() -> void:
	hideArrows()


func setCurrentVolume(value: int):
	currentVolume = clamp(value, 0, 10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audioChannel), linear2db(currentVolume/20.0))
	$Vol.rect_size = Vector2(16 * currentVolume, 16)
	if currentVolume == 0:
		$Vol.visible = false
	else:
		$Vol.visible = true


func increaseVol() -> void:
	self.currentVolume = currentVolume + 1
	$Up.frame = 0
	$Up.play("default")


func decreaseVol() -> void:
	self.currentVolume = currentVolume - 1
	$Down.frame = 0
	$Down.play("default")


func showArrows() -> void:
	$Down.visible = true
	$Up.visible = true


func hideArrows() -> void:
	$Down.visible = false
	$Up.visible = false
