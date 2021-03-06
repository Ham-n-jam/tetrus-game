extends MarginContainer

const NUM_INVIS_ROWS: int = 3

# Initialise the bg and game board, returning the game board
func init(blockSize: int=16, numCols: int=10, numRows: int=20) -> void:
	
	var bgBlock: TextureRect = TextureRect.new()
	
	# Load a particular .png texture depending on the block size for background blocks
	var loadBgBlock: String = "res://assets/sprites/%sbgblock.png" % String(blockSize)
	bgBlock.texture = load(loadBgBlock)
	$BoardContainer/BgBoard.init(bgBlock, numCols, numRows)
	
	var block: TextureRect = TextureRect.new()
	
	# Add the ghost shapes board
	$BoardContainer/GhostBoard.init(numCols, numRows, blockSize, NUM_INVIS_ROWS, true)
	
	# Load a particular .png texture depending on the block size for playing blocks
	var loadBlock: String = "res://assets/sprites/%sblock.png" % String(blockSize)
	block.texture = load(loadBlock)
	block.modulate.a = 0
	$BoardContainer/BlocksBoard.init(block, numCols, numRows, NUM_INVIS_ROWS)
	
	# Add the effects board
	$BoardContainer/EffectsBoard.init(numCols, numRows, blockSize, NUM_INVIS_ROWS)
