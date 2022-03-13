extends Node


func getKeyDispString(scancode: int) -> String:
	var dispStr: String = OS.get_scancode_string(scancode)
	dispStr = dispStr.to_upper()
	# Shorten keypad key strings from "Kp n" to "Kn" to fit UI better
	if("KP " in dispStr):
		return "K" + dispStr[3]
	else:
		match dispStr:
			"EQUAL":
				return "="
			"MINUS":
				return "-"
			"QUOTELEFT":
				return "`"
			"BACKSLASH":
				return "\\"
			"BRACERIGHT":
				return "]"
			"BRACELEFT":
				return "["
			"APOSTROPHE":
				return "'"
			"SEMICOLON":
				return ";"
			"SLASH":
				return "/"
			"PERIOD":
				return "."
			"COMMA":
				return ","
			"LEFT":
				return "˂"
			"RIGHT":
				return "˃"
			"UP":
				return "˄"
			"DOWN":
				return "˅"
			"SPACE":
				return "Ƶ"
			"SHIFT":
				return "Ƨ"
			"CONTROL":
				return "Ʒ"
			"ALT":
				return "ª"
			"TAB":
				return "Š"
			"ENTER":
				return "ˀ"
			"DELETE":
				return "ˁ"
			"ESCAPE":
				return "˥"
			"HOME":
				return "˥"
			"END":
				return "ư"
			"BACKSPACE":
				return "˿"
	return dispStr


func loadJson(jsonFilePath) -> Dictionary:
	var file = File.new();
	file.open(jsonFilePath, File.READ);
	var dataDict: Dictionary = parse_json(file.get_as_text())
	file.close()
	
	return dataDict


func saveJson(jsonFilePath: String, data: Dictionary) -> void:
	var file = File.new();
	file.open(jsonFilePath, File.WRITE);
	file.store_line(to_json(data))
	file.close()
