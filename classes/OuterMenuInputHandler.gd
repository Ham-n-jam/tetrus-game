class_name OuterMenuInputHandler
extends Control

onready var outerMenu = $OuterMenu

# Pass the event down the menu tree
func _input(ev):
	outerMenu.handleInput(ev)
