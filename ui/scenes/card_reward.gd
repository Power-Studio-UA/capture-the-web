extends Control
class_name CardReward

const my_scene : PackedScene = preload("res://ui/scenes/Card_reward_screen.tscn")
const card_scene : PackedScene = preload("res://ui/scenes/card_scene.tscn")
@export var reward_container : Container
@export var card_amount : int = 3
@export var skip_button : Button 
var selected_cards : Array
signal selection_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selection_finished.emit()
	skip_button.pressed.connect(func() : call_deferred("queue_free"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func _construct(card_data) -> CardReward:
	var obj = my_scene.instantiate() as CardReward
	var copied_data = card_data.duplicate(true)
	for i in obj.card_amount:
		var select = copied_data.keys().pick_random()
		copied_data.erase(select)
		obj.selected_cards.push_back(select)
		

	for card_id in obj.selected_cards:
		# print("Selected card: " + str(card_id))
		var card_obj = card_scene.instantiate() as Card
		card_obj.setup(card_data[card_id], obj.remove_reward, true, false)
		obj.reward_container.add_child(card_obj)

	return obj

func remove_reward(card_data, card_obj):
	var main_level = get_tree().get_first_node_in_group("main") as MainLevel
	# print("CARD WITH INDEX: " + str(selected_cards[selected_cards.find(card_obj)]))
	main_level.add_card_to_deck(selected_cards[selected_cards.find(card_obj)])
	selection_finished.emit()
	self.call_deferred("queue_free")
