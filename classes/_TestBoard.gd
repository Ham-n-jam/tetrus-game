extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shapeData: ShapeData = ShapeData.new()
	shapeData.init("I", ShaderMaterial.new(), [[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0],
			[0, 0, 0, 0]])
	
	shapeData.printState()
	print("rotate left")
	shapeData.rotateLeft()
	shapeData.printState()
	
	print("rotate right")
	shapeData.rotateRight()
	shapeData.printState()
	print("rotate right again")
	shapeData.rotateRight()
	shapeData.printState()
	print("rotate right again again")
	shapeData.rotateRight()
	shapeData.printState()
