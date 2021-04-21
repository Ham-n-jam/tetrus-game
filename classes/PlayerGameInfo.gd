extends Control

class_name PlayerGameInfo

func init(playerNum: int):
	$PlayerName.text = "Player %d" % playerNum


func setHoldBoard(nodes: Array):
	# Remove old children
	for node in $HoldBoardCont.get_children():
		node.queue_free()
	for node in nodes:
		$HoldBoardCont.add_child(node)
