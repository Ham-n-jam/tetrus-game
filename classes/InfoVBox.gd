extends VBoxContainer

class_name InfoVBox

var _contentChild: Array setget setContentChildren
var _label: Label

func _ready() -> void:
	_label = $Label


func setContentChildren(children: Array) -> void:
	_contentChild = children
	# Remove old children
	for node in $MarginContainer/MarginContainer/Content.get_children():
		node.queue_free()
	for child in children:
		$MarginContainer/MarginContainer/Content.add_child(child)


func setLabelText(text: String) -> void:
	_label.text = text.to_upper()
