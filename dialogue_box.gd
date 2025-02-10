@tool
extends HBoxContainer
class_name DialogueMessage

enum dialogueSide {LEFT = 0, RIGHT = 1}
@export var currentSide : dialogueSide :
	set(value):
		if currentSide != value:
			flip(value)
			currentSide = value
@export var dialogue_bg : TextureRect
@export var avatar : TextureRect
@export var message_label : RichTextLabel

const self_scene = preload("res://Dialogue_Box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flip(currentSide)


func flip(side : dialogueSide) -> void:
	match side:
		dialogueSide.LEFT:
			self.layout_direction = Control.LAYOUT_DIRECTION_RTL
			# move_child(avatar, 0)
			dialogue_bg.flip_h = true
		dialogueSide.RIGHT:
			self.layout_direction = Control.LAYOUT_DIRECTION_LTR
			# move_child(dialogue_bg, 0)
			dialogue_bg.flip_h = false

func update_text(message : String) -> void:
	message_label.text = message

	 # Add padding


static func constructor(message: String, side : dialogueSide)-> DialogueMessage:
	var obj = self_scene.instantiate()
	obj.flip(side)
	obj.update_text(message)
	obj.currentSide = side
	obj.dialogue_bg.size = obj.message_label.size + Vector2(50, 50) 
	return obj