extends Node
class_name Battle

signal battle_won
signal battle_lost

var battle_id
var battle_data
var player_patience = 10
var player_influence = 0
var current_step = 0
var player_deck = []

#func _ready():
	#battle_data = get_node("/root/Main").battles[battle_id]
	#setup_battle()
	
func setup(battle_info, deck_info):
	self.battle_data = battle_info
	setup_battle()

func setup_battle():
	update_stats()
	show_ai_replica()
	setup_player_deck()

func update_stats():
	var stats_container = $BattleUI/StatsContainer
	stats_container.get_node("Patience").text = "Patience: " + str(player_patience)
	stats_container.get_node("Influence").text = "Influence: " + str(player_influence)

func show_ai_replica():
	if current_step < battle_data.steps.size():
		var replicas = battle_data.steps[current_step].ai_replica
		var random_replica = replicas[randi() % replicas.size()]
		$BattleUI/AIDialog.text = random_replica

func setup_player_deck():
	var card_set = get_node("/root/Main").card_sets[battle_data.reward.card_set_id]
	var card_container = $BattleUI/CardContainer
	for card in card_set:
		create_card_button(card, card_container)

func create_card_button(card_data, container):
	var card_button = Button.new()
	card_button.text = card_data.replicas[0]
	#card_button.connect("pressed", self, "_on_card_played", [card_data])
	container.add_child(card_button)

func _on_card_played(card_data):
	apply_card_effects(card_data.effects)
	check_battle_state()
	current_step += 1
	show_ai_replica()

func apply_card_effects(effects):
	if effects.has("patience"):
		player_patience += effects.patience
	if effects.has("append_cards"):
		pass
	update_stats()

func check_battle_state():
	if player_patience <= 0:
		emit_signal("battle_lost")
	elif player_influence >= battle_data.ai_setup.target_interest:
		emit_signal("battle_won")
