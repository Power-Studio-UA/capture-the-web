@tool
extends HBoxContainer

enum dialogueSide {LEFT = 0, RIGHT = 1}
@export var currentSide : dialogueSide :
	set(value):
		if currentSide != value:
			flip(value)
			currentSide = value
@export var dialogue_bg : TextureRect
@export var avatar : TextureRect
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