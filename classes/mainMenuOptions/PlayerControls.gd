extends MenuController

onready var playerGameInfo = $PlayerGameInfo
var currentPlayer: int = 1

func _ready():
	hideArrows()
	currentPlayer = 1
	playerGameInfo.init(currentPlayer)
	description = "Remap this player's controls."
	for option in _options:
		option.connect("key_mapping_changed", self, "keyMappingChanged")


func keyMappingChanged():
	playerGameInfo.init(currentPlayer)


func onClick() -> bool:
	for option in _options:
		option._playerNum = currentPlayer
	$ControlsRemap/Label.text = "Remapping Player " + str(currentPlayer)
	startUpMenu("vertical")
	_isActive = true
	$AnimationPlayer.play("onClick")
	return true


func onHover() -> void:
	showArrows()


func onUnhover() -> void:
	hideArrows()


func onLeft() -> void:
	currentPlayer = posmod(currentPlayer - 2, 4) + 1
	playerGameInfo.init(currentPlayer)
	resetOptions()
	$Down.frame = 0
	$Down.play("default")


func onRight() -> void:
	currentPlayer = (currentPlayer) % 4 + 1
	playerGameInfo.init(currentPlayer)
	resetOptions()
	$Up.frame = 0
	$Up.play("default")

func resetOptions() -> void:
	for option in _options:
		option.get_node("Warning").visible = false


func showArrows() -> void:
	$Down.visible = true
	$Up.visible = true


func hideArrows() -> void:
	$Down.visible = false
	$Up.visible = false
