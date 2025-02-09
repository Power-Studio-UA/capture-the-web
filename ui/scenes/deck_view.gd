extends Control
class_name  DeckView

@export var card_container : Container 
@export var return_button : Button
const card_scene : PackedScene = preload("res://ui/scenes/card_scene.tscn")
const deck_view : PackedScene = preload("res://ui/scenes/deck_view.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return_button.pressed.connect(func() : queue_free())


func _add_card(card) -> void:
		var card_obj = card_scene.instantiate() as Card
		card_obj.setup(card, _print_something_nice, false)
		card_container.add_child(card_obj)


static func _print_something_nice(card_data, card_instance):
	print("YOU ARE BREATHTAKING")

static func _construct() -> DeckView:
	var obj = deck_view.instantiate()
	return obj
	