extends CenterContainer

class_name GameVLayout


var _boardContainer: MarginContainer
var _hold: InfoVBox
var _holdBoard: Board
var _next: InfoVBox
var _lines: InfoVBox
var _board: Board
var _shapeDataFactory: ShapeDataFactory = ShapeDataFactory.new()

enum _shapeTypes {O, T, S, Z, L, J, I}

func init(boardName: String="P1", blockSize: int=16, numCols: int=10, numRows: int=20, previewBlockSize: int=10):
	_boardContainer = $HBoxContainer/GameBoard/BoardContainer
	_hold = $HBoxContainer/TopVBox/Hold
	_next = $HBoxContainer/TopVBox/Next
	_lines = $HBoxContainer/TopVBox/BottomVBox/Lines
	_board = $HBoxContainer/GameBoard.init(boardName, blockSize, numCols, numRows)
	
	# Setup InfoVBoxes
	_hold.setLabelText("HOLD")
	_next.setLabelText("NEXT")
	_lines.setLabelText("LINES")
	
	var boldFont: DynamicFont = DynamicFont.new()
	boldFont.font_data = load("res://assets/fonts/bold.ttf")
	boldFont.size = 8
	var linesLabel: Label = Label.new()
	linesLabel.add_font_override("font", boldFont)
	linesLabel.text = "000"
	_lines.setContentChildren([linesLabel])
	
	var holdBgAndBoard: Array = createPreviewBlockWBg("T", previewBlockSize)
	_hold.setContentChildren(holdBgAndBoard)
	_holdBoard = holdBgAndBoard[1]
	
	var nextVBox: VBoxContainer = VBoxContainer.new()
	nextVBox.set("custom_constants/separation", 8)
	for shape in _shapeTypes:
		var cc: CenterContainer = CenterContainer.new()
		var preview = createPreviewBlockWBg(str(shape), previewBlockSize)
		cc.add_child(preview[0])
		cc.add_child(preview[1])
		
		nextVBox.add_child(cc)
	_next.setContentChildren([nextVBox])


# Create a preview shape with a grid background
func createPreviewBlockWBg(shape: String, previewBlockSize: int) -> Array:
	var pbgBlock: TextureRect = TextureRect.new()
	var loadPbgBlock: String = "res://assets/sprites/%spbgblock.png" % String(previewBlockSize)
	pbgBlock.texture = load(loadPbgBlock)
	var pbgBoard: Board = load("res://classes/Board.tscn").instance()
	pbgBoard.init("pbg", pbgBlock, 4, 2)

	var holdShape: Board = _shapeDataFactory.getShapePreviewGridContainer(shape, previewBlockSize)
	
	return [pbgBoard, holdShape]


func handle_hold_shape_changed(player: int, newShape: String):
	_holdBoard.transitionToNextStateArray(_shapeDataFactory.getShapePreview2DArray(newShape), _shapeDataFactory.getShapeMaterial(newShape))
