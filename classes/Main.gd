extends Control

func changeScene(nextSceneNode: Node):
	
	# Remove the current scene
	var currentScene = $CurrentScene.get_child(0)
	$CurrentScene.remove_child(currentScene)
	currentScene.call_deferred("free")
	
	# Add the next scene
	$CurrentScene.add_child(nextSceneNode)
