extends VBoxContainer

class_name InfoVBox

var _bg: NinePatchRect
var _contentChild: Array setget setContentChildren, getContentChildren
var _label: Label

func _ready() -> void:
	_bg = $MarginContainer/NinePatchRect
	_label = $Label


func resizeBgX(newX: float) -> void:
	_bg.rect_min_size = Vector2(newX, _bg.rect_minsize[1])
	_bg.rect_size = Vector2(newX, _bg.rect_minsize[1])


func resizeBgY(newY: float) -> void:
	_bg.rect_min_size = Vector2(_bg.rect_minsize[0], newY)
	_bg.rect_size = Vector2(_bg.rect_minsize[0], newY)


func setContentChildren(children: Array) -> void:
	_contentChild = children
	# Remove old children
	for node in $MarginContainer/MarginContainer/Content.get_children():
		node.queue_free()
	for child in children:
		$MarginContainer/MarginContainer/Content.add_child(child)


func getContentChildren() -> Array:
	return _contentChild


func setLabelText(text: String) -> void:
	_label.text = text.to_upper()


func getLabelText() -> String :
	return _label.text
