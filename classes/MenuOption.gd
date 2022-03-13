extends Control

class_name MenuOption

var description: String = "..."


# Return true if this node acts as a submenu
func onClick() -> bool:
	return false


func onHover() -> void:
	pass


func onUnhover() -> void:
	pass


func onLeft() -> void:
	pass


func onRight() -> void:
	pass


func handleInput(_ev: InputEvent) -> bool:
	return false
