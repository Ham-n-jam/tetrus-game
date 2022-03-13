class_name MenuController
extends MenuOption

var _options: Array = []
var _isActive: bool = false
var _currentlySelected: int
var _subMenu: MenuOption = null
var _menuType: String
onready var _tween = $ChangeTween
onready var _description = $Description
export var _unselectedColour: Color = GlobalColours.infoBoxBg
export var _selectedColour: Color = GlobalColours.uiHighlight
export var _menuOptionsGroup: String = "menuOptions"
export var _isSubmenu: bool = false
export var _startupTime: float = 1.0

func _ready() -> void:
	_options = get_tree().get_nodes_in_group(_menuOptionsGroup)
	for option in _options:
		option.find_node("Bg").modulate = _unselectedColour
	_hide()


func _hide() -> void:
	for option in _options:
		option.modulate = Color(1, 1, 1, 0)


func startUpMenu(menuType: String) -> void:
	_tween.stop_all()
	# Fade in options
	for option in _options:
		option.find_node("Bg").modulate = _unselectedColour
		option.find_node("Label").modulate = Color.white
		_tween.interpolate_property(option, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), _startupTime, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween, "tween_completed")
	
	_menuType = menuType
	_isActive = true
	_subMenu = null
	_currentlySelected = 0
	_changeSelection(_currentlySelected)
	MenuControlsGuide.fadeIn()


func shutDownMenu() -> void:
	_options[_currentlySelected].onUnhover()
	_isActive = false
	for option in _options:
		option.find_node("Bg").modulate = _unselectedColour
		option.find_node("Label").modulate = Color.white
	
	# Fade out options
	for option in _options:
		_tween.interpolate_property(option, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), _startupTime, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT)
	_tween.interpolate_property(_description, "percent_visible", 1, 0, 0.2)
	_tween.start()
	
	yield(_tween, "tween_completed")


func _fadeCurrentToNormal() -> void:
	var currentBg = _options[_currentlySelected].find_node("Bg")
	_tween.interpolate_property(currentBg, "modulate", 
		null, _unselectedColour, 0.2
	)
	_tween.start()
	_options[_currentlySelected].find_node("Label").modulate = Color.white


func _changeSelection(newSelection: int) -> void:
	_options[_currentlySelected].onUnhover()
	_options[newSelection].onHover()
	
	# Change out description text
	_description.percent_visible = 0
	_description.text = _options[newSelection].description
	_tween.interpolate_property(_description, "percent_visible", 0, 1, 0.2)
	
	if (newSelection != _currentlySelected):
		# Fade current selection back to unselected
		_fadeCurrentToNormal()
		SfxPlayerSingleton.playSfx("Change")
	
	# Highlight new selection
	_options[newSelection].find_node("Label").modulate = Color("#111111")
	_currentlySelected = newSelection
	var newBg = _options[newSelection].find_node("Bg")
	_tween.interpolate_property(newBg, "modulate", 
		null, _selectedColour, 0.2
	)
	_tween.start()


func handleInput(ev: InputEvent):
	if ev is InputEventKey and ev.pressed and _isActive:
		if (_subMenu):
			# Control is currently in a submenu, pass it the event
			if (!_subMenu.handleInput(ev)):
				# Control returned to this node
				_subMenu = null
				_changeSelection(_currentlySelected)
			return true
		
		else:
			match ev.scancode:
				KEY_LEFT:
					if (_menuType == "horizontal"):
						var newSelection = (_currentlySelected - 1) % _options.size() 
						_changeSelection(newSelection)
					else:
						_options[_currentlySelected].onLeft()
				
				KEY_RIGHT:
					if (_menuType == "horizontal"):
						var newSelection = (_currentlySelected + 1) % _options.size() 
						_changeSelection(newSelection)
					else:
						_options[_currentlySelected].onRight()
				
				KEY_UP:
					if (_menuType == "vertical"):
						var newSelection = (_currentlySelected - 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_DOWN:
					if (_menuType == "vertical"):
						var newSelection = (_currentlySelected + 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_ENTER, KEY_SPACE:
					# Click the current selection. If it has a submenu, enter it
					# and set control to it
					if (_options[_currentlySelected].onClick()):
						_subMenu = _options[_currentlySelected]
						
						SfxPlayerSingleton.playSfx("Confirm")
						_fadeCurrentToNormal()
						_tween.interpolate_property(_description, "percent_visible", 1, 0, 0.2)
						_tween.start()
				
				KEY_BACKSPACE:
					if (_isSubmenu):
						SfxPlayerSingleton.playSfx("Cancel")
						$AnimationPlayer.play_backwards("onClick")
						shutDownMenu()
						return false
			return true
