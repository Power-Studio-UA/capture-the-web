# Battle.gd
extends Node2D

var current_patience = 10
var current_influence = 0
var opponent_next_move = ""
var cards = []
var player_state = {}
var battle_info = {}

# Node references
@onready var chat_log = $BattleScene/ChatLog
@onready var cards_container = $BattleScene/CardsContainer
@onready var patience_label = $BattleScene/Stats/Patience
@onready var influence_label = $BattleScene/Stats/Influence
@onready var opponent_move_label = $BattleScene/OpponentMove

func setup(battle_info, player_state, card_data):
	self.player_state = player_state
	self.battle_info = battle_info

	var card_instances = []
	for card_id in player_state['deck'].keys():
		var count = player_state['deck'][card_id]
		if card_id in card_data:
			for i in range(count):
				card_instances.append(card_data[card_id].duplicate(true)) # Deep copy to avoid reference issues

	self.setup_deck(card_instances)
	print(self.cards)

func setup_deck(cards):
	for card_data in cards:
		var card = preload("res://modules/card/card.tscn").instance()
		card.setup(card_data)
		card.connect("card_played", self, "_on_card_played")
		cards_container.add_child(card)
		self.cards.append(card_data)


#func _ready():
	#setup_battle()
#
#func setup_battle():
	#update_stats()
	#show_opponent_move()
	#setup_initial_hand()
#
#func show_opponent_move():
	#opponent_next_move = "Opponent will use: +2 rep"
	#opponent_move_label.text = opponent_next_move
	#add_chat_message("Opponent: " + opponent_next_move)
#
#func setup_initial_hand():
	#var card_data = {
		#"effects": {
			#"patience": 1,
			#"append_cards": 1
		#},
		#"replicas": [
			#"Message 1",
			#"Message 2",
			#"Message 3"
		#]
	#}
	#
	## Add some test cards
	#for i in range(4):
		#add_card_to_hand(card_data)
#
#func add_card_to_hand(card_data: Dictionary):
	#var card = preload("res://modules/card/card.tscn").instance()
	#card.setup(card_data)
	#card.connect("card_played", self, "_on_card_played")
	#cards_container.add_child(card)
	#cards.append(card_data)
#
#func _on_card_played(card_data: Dictionary):
	## Apply card effects
	#if card_data.effects.has("patience"):
		#current_patience += card_data.effects.patience
	#if card_data.effects.has("append_cards"):
		## Add new cards
		#pass
	#
	## Add message to chat
	#var message = card_data.replicas[randi() % card_data.replicas.size()]
	#add_chat_message("Player: " + message)
	#
	#update_stats()
#
#func add_chat_message(text: String):
	#var label = Label.new()
	#label.text = text
	#chat_log.add_child(label)
#
#func update_stats():
	#patience_label.text = "Patience: " + str(current_patience)
	#influence_label.text = "Influence: " + str(current_influence)
#
#func _on_EndTurn_pressed():
	## Process opponent's move
	#current_influence += 2  # For this example
	#update_stats()
	## Show next opponent move
	#show_opponent_move()
#
#func _on_Leave_pressed():
	## Return to previous scene
	#queue_free()
