extends Control
class_name CardHand

const MIN_SPACING : float = 30
const MAX_SPACING : float = 250

func arrange_cards():
	var card_count = get_child_count()
	if card_count == 0:
		return

	var hand_width = 800 
	var card_width = get_child(0).get_rect().size.x  

	var spacing = min(MAX_SPACING, max(MIN_SPACING, hand_width / card_count))
	var total_width = (card_count - 1) * spacing
	
	var start_x = -total_width / 2  # Start positioning from center
	for i in range(card_count):
		var card = get_child(i)
		card.position = Vector2(i * spacing, -80)
		card.base_position = card.position
		card.z_index = i 
		
func _ready():
	arrange_cards()

func _on_card_added(card : Card):
	add_child(card)
	arrange_cards()
	
func _on_card_removed(card : Card):
	remove_child(card)
	arrange_cards()
