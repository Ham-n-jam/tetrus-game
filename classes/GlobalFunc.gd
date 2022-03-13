extends Node


func getKeyDispString(scancode: int) -> String:
	var dispStr: String = OS.get_scancode_string(scancode)
	
	# Shorten keypad key strings from "Kp n" to "Kn" to fit UI better
	if("Kp " in dispStr):
		return "K" + dispStr[3]
	elif dispStr == "BackSpace":
		return "Bs"
	elif dispStr == "Enter":
		return "En"
	else:
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
