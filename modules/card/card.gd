extends Node2D

signal card_played(card_data)

var data = {}
var button_pressed_callback = func(data, card_instance): pass

func setup(card_data: Dictionary, button_pressed_callback: Callable):
	data = card_data
	self.button_pressed_callback = button_pressed_callback
	$VBoxContainer/Description.text = get_effects_text(data.effects)

func get_effects_text(effects: Dictionary) -> String:
	var text = ""
	if effects.has("patience"): text += "Patience: " + str(effects.patience) + "\n"
	if effects.has("mem"): text += "Memory: " + str(effects.patience) + "\n"
	if effects.has("append_cards"): text += "Draw: " + str(effects.append_cards)
	return text

func _on_play_btn_pressed() -> void:
	self.button_pressed_callback.call(data, self)
	#emit_signal("card_played", data)
	#queue_free()
	
