extends Node

class_name ShapeData

const CELL_CLEAR_VAL: int = 0
const CELL_LOCKED_IN_VAL: int = 2

enum _StateEnum {NOT_ON_BOARD, STALLED, FALLING, CHECK, LOCKED_IN, LOCK_DELAY}

var _shapeType: String
var _material: ShaderMaterial
var _state2DArray: Array setget setArray, getArray
var _orientation: int = 0 # Number in range 0-3, rotating to right increases by 1
var _position: Vector2 = Vector2(-1, -1) # (Row, Col) position in board
var _state: int = _StateEnum.NOT_ON_BOARD
var _rotationsLeftUntilLock: int = 15 # If it hits 0, shape is force locked into board

func init(shapeType: String, material: ShaderMaterial, state2DArrray: Array):
	_shapeType = shapeType
	_material = material
	_state2DArray = state2DArrray 


# Rotate _state2DArray anti-clockwise
func getRotateLeft() -> Array:
	var newArray: Array = _state2DArray.duplicate(true)
	for i in newArray.size():
		for j in newArray.size():
			newArray[(newArray.size()-1)-j][i] = _state2DArray[i][j]
	
	return newArray


# Rotate _state2DArray clockwise
func getRotateRight() -> Array:
	var newArray: Array = _state2DArray.duplicate(true)
	var N = newArray.size()
	for i in range(N / 2):
		for j in range(i, N - i - 1):
			var temp = newArray[i][j]
			newArray[i][j] = newArray[N - 1 - j][i]
			newArray[N - 1 - j][i] = newArray[N - 1 - i][N - 1 - j]
			newArray[N - 1 - i][N - 1 - j] = newArray[j][N - 1 - i]
			newArray[j][N - 1 - i] = temp
	
	return newArray


func getLowestRowNumWithCellPresent() -> int:
	var lowestRow: int = -1

	for i in range(0, _state2DArray.size()):
		for val in _state2DArray[i]:
			if (val != CELL_CLEAR_VAL):
				lowestRow = i
	
	return lowestRow


func doRotateLeft(offset: Vector2):
	setArray(getRotateLeft())
	_orientation = int(fposmod(_orientation - 1, 4))
	_position += offset


func doRotateRight(offset: Vector2):
	setArray(getRotateRight())
	_orientation = int(fposmod(_orientation + 1, 4))
	_position += offset


func setArray(state2DArray: Array) -> void:
	_state2DArray = state2DArray


func getArray() -> Array:
	return _state2DArray
