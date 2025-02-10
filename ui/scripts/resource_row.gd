@tool
extends Control
class_name  ResourceRow

enum Ingame_Resources {MEM = 0, REP = 1, PATIENCE = 2, INT = 3} 
@export var array : Array[String]
@export var horBox : HBoxContainer
@export var resource_amount : int :
	set(value):
		if resource_amount != value:
			resource_amount = value
			_update_text()

@export var resource_type : Ingame_Resources :
	set(value):
		if resource_type != value:
			resource_type = value
			_update_image()

@export var image : TextureRect
@export var left_text_label : RichTextLabel
@export var right_text_label : RichTextLabel

@export var leftTextVisible : bool : 
	set(value):
		if value != leftTextVisible:
			leftTextVisible = value
			if left_text_label:
				left_text_label.visible = leftTextVisible
				_update_aligmnet()

@export var rightTextVisible : bool : 
	set(value):
		if value != rightTextVisible:
			rightTextVisible = value
			if right_text_label:
				right_text_label.visible = rightTextVisible
				_update_aligmnet()

@export var text_size : int :
	set(value):
		if text_size != value:
			text_size = value
			_update_size(text_size)


const self_scene = preload("res://ui/scenes/resource_row.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_resource(resource_amount, resource_type)

func _update_text() -> void:
	if left_text_label:
		left_text_label.text = "[right]" + str(resource_amount)
	if right_text_label:
		right_text_label.text = "[left]" + str(resource_amount)

func _update_resource(amount : int, type : Ingame_Resources) -> void:
	resource_amount = amount
	resource_type = type
	_update_text()
	_update_image()

static func constructor(amount : int, type : Ingame_Resources)-> ResourceRow:
	var obj = self_scene.instantiate()
	obj._update_resource(amount, type)
	return obj

func _update_size(size : int):
	if right_text_label:
		right_text_label.add_theme_font_size_override("normal_font_size", size)
	if left_text_label:
		left_text_label.add_theme_font_size_override("normal_font_size", size)

func _update_image() -> void:
	var index = resource_type
	if (array.size() > index && image):
		image.texture = load("res://assets/textures/" + array[index])

func _update_aligmnet() -> void:
	if horBox:
		if rightTextVisible && !leftTextVisible:
			horBox.alignment = BoxContainer.ALIGNMENT_BEGIN
		elif leftTextVisible && !rightTextVisible:
			horBox.alignment = BoxContainer.ALIGNMENT_END
		else :
			horBox.alignment = BoxContainer.ALIGNMENT_CENTER
