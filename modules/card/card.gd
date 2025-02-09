extends Control
class_name Card


signal card_played(card_data)

var data = {}
var button_pressed_callback = func(data, card_instance): pass
@export var description : RichTextLabel
@export var patience_cost_label : ResourceRow
@export var card_name : RichTextLabel
@export var image : TextureRect

func setup(card_data: Dictionary, button_pressed_callback: Callable):
	$Button.pressed.connect(_on_play_btn_pressed)
	data = card_data
	self.button_pressed_callback = button_pressed_callback
	description.text = get_effects_text(data.effects)
	card_name.text = data.title
	if data.effects.has("patience"):
		patience_cost_label.resource_amount = data.effects.patience
	image.texture = load(data.image)

func get_effects_text(effects: Dictionary) -> String:
	var text = ""
	if effects.has("mem"): text += "[p]Memory: " + str(effects.mem) + "[/p]"
	if effects.has("append_cards"): text += "[p]Draw: " + str(effects.append_cards) + "[/p]"
	return text

func _on_play_btn_pressed() -> void:
	self.button_pressed_callback.call(data, self)


# Called every frame. 'delta' is the elapsed time since the previous frame.