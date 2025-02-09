# Battle.gd
extends Node
class_name Battle

var current_patience = 10
var current_report = 10
var current_influence = 0
var opponent_next_move = ""

var current_step = 0

var deck_cards = []
var in_hand = []
var thrown_cards = []

var hand_max_cards = 3

var player_state = {}
var battle_info = {}
var card_data = {}
var current_turn: int = 1

# Node references
@export var chat_log: VBoxContainer
@export var cards_container: CardHand
@export var patience_label: ResourceRow
@export var influence_label: ResourceRow
@export var report_label : ResourceRow
@export var opponent_move_label: Label
@export var leave_button: Button
@export var end_turn_button: Button
@export var turn_label: RichTextLabel

# Signals
signal matchLeft

func setup(battle_info, player_state, card_data):
	self.player_state = player_state
	self.battle_info = battle_info
	self.card_data = card_data
	self.current_patience = self.battle_info['ai_setup']['patience']
	for child in chat_log.get_children():
		chat_log.remove_child(child)
	return self

func card_callback(card_data, card_instance):
	self.thrown_cards.append(card_data)
	cards_container._on_card_removed(card_instance)
	print(card_data["id"])
	var replicas = card_data["replicas"]
	self.add_chat_message(replicas[randi() % replicas.size()], false)
	for i in range(self.in_hand.size()):
		if self.in_hand[i]["id"] == card_data["id"]:
			self.in_hand.remove_at(i)
			break # Stop after removing the first match
	
	if len(self.in_hand) == 0:
		self.fill_hand_cards()

func handle_step_change():
	if len(battle_info['steps']) - 1 == self.current_step:
		self.check_battle_state()
		return

	self.apply_opponent_effect(self.battle_info['steps'][self.current_step])
	self.fill_hand_cards()
	self.current_step += 1

func draw_in_hand(cards):
	for card_data in cards:
		var card = preload("res://ui/scenes/card_scene.tscn").instantiate()
		card.setup(card_data, card_callback)
		cards_container._on_card_added(card)

func setup_deck(cards):
	var in_hand_cards_ = cards.slice(0, self.hand_max_cards)
	for card_data in in_hand_cards_:
		var card = preload("res://ui/scenes/card_scene.tscn").instantiate()
		card.setup(card_data, card_callback)
		#card.connect("card_played", self, "_on_card_played")
		cards_container._on_card_added(card)
		self.in_hand.append(card_data)
	
	self.deck_cards = cards.slice(self.hand_max_cards)


func _ready():
	var card_instances = []
	
	for card_id in self.player_state['deck'].keys():
		var count = self.player_state['deck'][card_id]
		if card_id in self.card_data:
			for i in range(count):
				var result_card = card_data[card_id].duplicate(true)
				result_card.merge({"id": card_id})
				card_instances.append(result_card) # Deep copy to avoid reference issues

	self.setup_deck(card_instances)
	setup_battle()
	leave_button.pressed.connect(func() -> void: matchLeft.emit())
	end_turn_button.pressed.connect(_on_EndTurn_pressed)
#
func setup_battle():
	update_stats()
	show_opponent_move()
	
func check_battle_state():
	if self.current_patience <= 0:
		self.lose_fn()

	if self.current_influence >= self.battle_info['ai_setup']['target_interest']:
		self.win_fn()


func lose_fn():
	pass

func win_fn():
	pass

func show_opponent_move():
	var ai_move = self.battle_info['steps'][self.current_step]['ai_move']
	var opponent_next_move = ""
	if ai_move.has("patience"): opponent_next_move += "Patience: " + str(ai_move.patience)
	#if ai_move.has("mem"): text += "Memory: " + str(effects.patience) + "\n"
	#if ai_move.has("append_cards"): text += "Draw: " + str(effects.append_cards)

	opponent_move_label.text = "MY MOVE " + opponent_next_move
	add_chat_message("Opponent: " + opponent_next_move, true)
	
func apply_effect_dict(effects):
	if effects.has("patience"):
		add_chat_message("Applying effect: Patience" + str(effects.patience), false)
		self.current_patience += effects.patience
		
	if effects.has("influence"):
		add_chat_message("Applying effect: Influence" + str(effects.influence), false)
		self.current_influence += effects.current_influence
		
	if effects.has("append_cards"):
		#TODO
		pass

func apply_card_effect(card_data):
	var effects = card_data['effects']
	self.apply_effect_dict(effects)

func apply_opponent_effect(opponent_data):
	var effects = opponent_data['ai_move']
	self.apply_effect_dict(effects)
	self.check_battle_state()

func sync_deck_cards():
	if len(self.deck_cards) == 0:
		self.deck_cards = self.thrown_cards
		self.thrown_cards = []
		
func fill_hand_cards():
	var num_to_pick = self.hand_max_cards - len(self.in_hand)
	if len(self.deck_cards) < num_to_pick:
		self.sync_deck_cards()
	
	var new_deck = self.deck_cards.slice(num_to_pick)
	var drawn_cards = self.deck_cards.slice(0, num_to_pick)
	self.deck_cards = new_deck
	self.in_hand += drawn_cards
	draw_in_hand(drawn_cards)
	
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
##
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
func add_chat_message(text: String, isOpponent: bool):
	var obj
	if isOpponent:
		obj = DialogueMessage.constructor(text, DialogueMessage.dialogueSide.LEFT)
	else:
		obj = DialogueMessage.constructor(text, DialogueMessage.dialogueSide.RIGHT)
	chat_log.add_child(obj)
#
func update_stats():
	patience_label.resource_amount = current_patience
	if (current_patience <=0):
		matchLeft.emit()
	influence_label.resource_amount = current_influence
	report_label.resource_amount = current_report
#
func _on_EndTurn_pressed():
	# Process opponent's move
	current_turn += 1
	turn_label.text = "[b]TURN " + str(current_turn)
	current_patience -= current_turn
	current_report-=2
	update_stats()
	# Show next opponent move
	show_opponent_move()
	fill_hand_cards()

#func _on_Leave_pressed():
	## Return to previous scene
	#queue_free()
