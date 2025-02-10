extends Control
class_name Card


signal card_played(card_data)

var data = {}
var button_pressed_callback = func(data, card_instance): pass
@export var description : RichTextLabel
@export var patience_cost_label : ResourceRow
@export var card_name : RichTextLabel
@export var image : TextureRect

var base_z_index = 0
var base_position = 0

func _ready() -> void:
	base_z_index = z_index

func setup(card_data: Dictionary, button_pressed_callback: Callable, isPlayable : bool = true, isMovable : bool = true):
	
	$Button.pressed.connect(_on_play_btn_pressed)
	if isMovable:
		$Button.mouse_entered.connect(_on_hover)
		$Button.mouse_exited.connect(_on_hover_left)

	if !isPlayable:
		remove_child($Button)
	

	data = card_data
	self.button_pressed_callback = button_pressed_callback
	description.text = "[center]"+ card_data.description
	card_name.text = "[center]"+data.title
	if data.effects.has("patience"):
		patience_cost_label.resource_amount = data.effects.patience
	image.texture = load(data.image)

# func get_effects_text(effects: Dictionary) -> String:
# 	var text = ""
# 	if effects.has("mem"): text += "[p]Memory: " + str(effects.mem) + "[/p]"
# 	if effects.has("append_cards"): text += "[p]Draw: " + str(effects.append_cards) + "[/p]"
# 	return text

func _on_play_btn_pressed() -> void:
	self.button_pressed_callback.call(data, self)

func _on_hover():
	z_index = 100
	position.y-=20

func _on_hover_left():
	z_index = base_z_index
	position = base_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
