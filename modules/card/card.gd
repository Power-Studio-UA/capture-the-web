extends Node2D

signal card_played(card_data)

var data = {}

func setup(card_data: Dictionary):
	data = card_data
	$VBoxContainer/Description.text = get_effects_text(data.effects)

func get_effects_text(effects: Dictionary) -> String:
	var text = ""
	if effects.has("patience"): text += "Patience: " + str(effects.patience) + "\n"
	if effects.has("mem"): text += "Memory: " + str(effects.patience) + "\n"
	if effects.has("append_cards"): text += "Draw: " + str(effects.append_cards)
	return text

func _on_PlayButton_pressed():
	emit_signal("card_played", data)
	queue_free()
