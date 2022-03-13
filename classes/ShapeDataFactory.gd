extends Node

class_name ShapeDataFactory

const _2DArraysDict: Dictionary = {
	"O":   [[1, 1],
			[1, 1]],
	
	"T":   [[0, 1, 0],
			[1, 1, 1],
			[0, 0, 0]],

	"S":   [[0, 1, 1],
			[1, 1, 0],
			[0, 0, 0]],

	"Z":   [[1, 1, 0],
			[0, 1, 1],
			[0, 0, 0]],

	"L":   [[0, 0, 1],
			[1, 1, 1],
			[0, 0, 0]],

	"J":   [[1, 0, 0],
			[1, 1, 1],
			[0, 0, 0]],

	"I":   [[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0],
			[0, 0, 0, 0]],
}
# 2*4 Preview arrays for HOLD and NEXT, etc
const _2DArraysPreviewDict: Dictionary = {
	"O":   [[0, 1, 1, 0],
			[0, 1, 1, 0]],
	
	"T":   [[0, 1, 0, 0],
			[1, 1, 1, 0]],
	
	"S":   [[0, 1, 1, 0],
			[1, 1, 0, 0]],
	
	"Z":   [[1, 1, 0, 0],
			[0, 1, 1, 0]],
	
	"L":   [[0, 0, 1, 0],
			[1, 1, 1, 0]],
	
	"J":   [[1, 0, 0, 0],
			[1, 1, 1, 0]],
	
	"I":   [[0, 0, 0, 0],
			[1, 1, 1, 1]]
}

var _availablePalettesDict: Dictionary
var _shapeTypePaletteDict: Dictionary
var _shapeTypeMaterialsDict: Dictionary


func _init() -> void:
	# Get available palettes for the shapes from the json
	_availablePalettesDict = GlobalFunc.loadJson("res://assets/palettes/json/palettes.json")
	_shapeTypePaletteDict = GlobalFunc.loadJson("res://assets/palettes/json/block_colours.json")
	
	# For each block type, init a palette material for that type with a certain colour
	for key in _shapeTypePaletteDict.keys():
		var mat: ShaderMaterial = ShaderMaterial.new()
		mat.shader = load("res://assets/palettes/uv_palette.shader")
		mat.set_shader_param("palette", load(_availablePalettesDict[_shapeTypePaletteDict[key]]))
		_shapeTypeMaterialsDict[key] = mat


func getShapeData(shape: String) -> ShapeData:
	var data = ShapeData.new()
	data.init(shape, getShapeMaterial(shape), getShape2DArray(shape))
	return data 


func getShapeMaterial(shape: String) -> ShaderMaterial:
	return _shapeTypeMaterialsDict[shape]


func getShape2DArray(shape: String) -> Array:
	return _2DArraysDict[shape].duplicate(true)


func getShapePreview2DArray(shape: String) -> Array:
	return _2DArraysPreviewDict[shape].duplicate(true)
