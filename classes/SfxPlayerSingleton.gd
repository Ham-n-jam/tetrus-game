extends Node


func playSfx(sfxName: String) -> void:
	var sfx: AudioStreamPlayer = self.get_node(sfxName)
	sfx.play()
