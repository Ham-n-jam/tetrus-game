extends Control

class_name MenuOption

var description: String = "..."


# Return true if this node acts as a submenu
func onClick() -> bool:
	return false


func handleInput(ev: InputEvent) -> bool:
	return false