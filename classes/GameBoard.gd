extends MarginContainer

const NUM_INVIS_ROWS: int = 3

# Initialise the bg and game board, returning the game board
func init(blockSize: int=16, numCols: int=10, numRows: int=20) -> Board:
	
	var bgBlock: TextureRect = TextureRect.new()
	
	# Load a particular .png texture depending on the block size for background blocks
	var loadBgBlock: String = "res://assets/sprites/%sbgblock.png" % String(blockSize)
	bgBlock.texture = load(loadBgBlock)
	
	# Add the background board
	var bgBoard: Board = load("res://classes/Board.tscn").instance()
	bgBoard.init(bgBlock, numCols, numRows)
	$BoardContainer.add_child(bgBoard)
	
	var block: TextureRect = TextureRect.new()
	
	# Load a particular .png texture depending on the block size for playing blocks
	var loadBlock: String = "res://assets/sprites/%sblock.png" % String(blockSize)
	block.texture = load(loadBlock)
	block.modulate.a = 0
	
	# Add the playing board
	var board: Board = load("res://classes/Board.tscn").instance()
	board.init(block, numCols, numRows, NUM_INVIS_ROWS)
	$BoardContainer.add_child(board)
	
	return board
