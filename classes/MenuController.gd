extends Control

var _options: Array = []
var _isActive: bool = false
var _currentlySelected: int
var _subMenu: MenuOption = null
var _menuType: String


func _ready() -> void:
	_options = get_tree().get_nodes_in_group("menuOptions")


func startUpMenu(menuType: String) -> void:
	_menuType = menuType
	_isActive = true
	_currentlySelected = 0
	_changeSelection(_currentlySelected)


func _fadeCurrentToNormal() -> void:
	var currentBg = _options[_currentlySelected].find_node("Bg")
	$ChangeTween.interpolate_property(currentBg, "modulate", 
		null, GlobalColours.infoBoxBg, 0.2
	)
	$ChangeTween.start()
	_options[_currentlySelected].find_node("Label").modulate = Color.white


func _changeSelection(newSelection: int) -> void:
	
	# Change out description text
	$Description.percent_visible = 0
	$Description.text = _options[newSelection].description
	$ChangeTween.interpolate_property($Description, "percent_visible", 
		0, 1, 0.2
	)
	
	if (newSelection != _currentlySelected):
		# Fade current selection back to unselected
		_fadeCurrentToNormal()
		$ChangeSfx.play()
	
	# Highlight new selection
	_options[newSelection].find_node("Label").modulate = Color("#111111")
	_currentlySelected = newSelection
	var newBg = _options[newSelection].find_node("Bg")
	$ChangeTween.interpolate_property(newBg, "modulate", 
		null, GlobalColours.uiHighlight, 0.2
	)
	$ChangeTween.start()


func _input(ev):
	if ev is InputEventKey and ev.pressed and _isActive:
		if (_subMenu):
			# Control is currently in a submenu, pass it the event
			if (!_subMenu.handleInput(ev)):
				# Control returned to this node
				_subMenu = null
				_changeSelection(_currentlySelected)
		
		else:
			match ev.scancode:
				KEY_LEFT:
					if (_menuType == "horizontal"):
						var newSelection = (_currentlySelected - 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_RIGHT:
					if (_menuType == "horizontal"):
						var newSelection = (_currentlySelected + 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_UP:
					if (_menuType == "vertical"):
						var newSelection = (_currentlySelected - 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_RIGHT:
					if (_menuType == "vertical"):
						var newSelection = (_currentlySelected + 1) % _options.size() 
						_changeSelection(newSelection)
				
				KEY_ENTER, KEY_SPACE:
					# Click the current selection. If it has a submenu, enter it
					# and set control to it
					if (_options[_currentlySelected].onClick()):
						_subMenu = _options[_currentlySelected]
						
						$ConfirmSfx.play()
						_fadeCurrentToNormal()
						
