extends Node
class_name NewEncounter

enum EncounterStates {UNSELECTED, CHOICE, BATTLE, SUCCESS, FAILURE}

var encounter_data
var current_state = EncounterStates.UNSELECTED
var battle_instance = null
var instantiated = false
var battle_id = ""
var was_battle : bool = false 
@export var description_label : RichTextLabel
@export var options_container : Container
@export var encounter_root : Node
var result_screen : ResultScreen
var rewards : Dictionary

var config_callback: Callable = func(): 
	return {}

func setup(data, config_callback: Callable):
	self.encounter_data = data
	self.config_callback = config_callback
	change_state(EncounterStates.UNSELECTED)

	return self

func ready():
	self.instantiated = true
	change_state(EncounterStates.CHOICE)
	

func change_state(new_state):
	# Clean up current state
	if instantiated:
		match current_state:
			EncounterStates.CHOICE:
				encounter_root.visible = false
			EncounterStates.BATTLE:
				if battle_instance:
					battle_instance.queue_free()
					battle_instance = null
					was_battle = true
			EncounterStates.SUCCESS:
				if result_screen:
					result_screen.visible = false
			EncounterStates.FAILURE:
				$GameOverUI.visible = false

	current_state = new_state

	if instantiated:
		match current_state:
			EncounterStates.CHOICE:
				setup_encounter_choices()
			EncounterStates.BATTLE:
				start_battle()
			EncounterStates.SUCCESS:
				show_reward()
			EncounterStates.FAILURE:
				show_failure_screen()

func list_all_nodes(node, indent=0):
	print("  ".repeat(indent) + node.name)  # Indent for hierarchy visualization
	for child in node.get_children():
		list_all_nodes(child, indent + 1)  # Recursive call for child nodes


func setup_encounter_choices():
	#list_all_nodes(self)
	#print(self.get_children())
	#self.get_node("EncounterUI").visible = true
	self.visible = true
	description_label.text = encounter_data.description
	setup_options()

func setup_options():
	# Clear existing options
	for child in options_container.get_children():
		child.queue_free()
	
	for option in encounter_data.options:
		var button = Button.new()
		button.text = option.text
		button.pressed.connect(Callable(_on_option_selected).bind(option))

		#button.connect("pressed", self, "_on_option_selected", [option])
		options_container.add_child(button)

func _on_option_selected(option):
	apply_effects(option.effects)
	if option.effects.has("battle_id"):
		self.battle_id = option.effects['battle_id']
		change_state(EncounterStates.BATTLE)
	else:
		if option.effects.has("mem"):
			rewards.get_or_add(ResourceRow.Ingame_Resources.MEM, option.effects.mem)
		if option.effects.has("rep"):
			rewards.get_or_add(ResourceRow.Ingame_Resources.REP, option.effects.rep)
		change_state(EncounterStates.SUCCESS)

func apply_effects(effects):
	# Apply encounter effects
	pass

func start_battle():
	#{"player_state": self.player_state, "cards": self.cards, "battles": self.battles}
	var config = self.config_callback.call()
	
	battle_instance = preload("res://ui/scenes/battle_scene.tscn").instantiate().setup(
		config["battles"][self.battle_id],
		config["player_state"], 
		config["cards"]
		)
	#battle_instance.connect("battle_won", self, "_on_battle_won")
	#battle_instance.connect("battle_lost", self, "_on_battle_lost")
	add_child(battle_instance)
	battle_instance.matchLeft.connect(show_failure_screen)

func _on_battle_won():
	change_state(EncounterStates.SUCCESS)

func _on_battle_lost():
	change_state(EncounterStates.FAILURE)

func show_reward():
	if was_battle:
		var main_level = get_tree().get_first_node_in_group("main") as MainLevel
		var card_selection = CardReward._construct(main_level.cards)
		add_child(card_selection)
		card_selection.selection_finished.connect(_show_success_screen)
	else:
		_show_success_screen()

func show_failure_screen():
	if (result_screen == null):
		battle_instance.call_deferred("queue_free")
		result_screen = ResultScreen._construct(encounter_data.name, rewards, false)
		add_child(result_screen)
	else:
		result_screen.visible = true

func _show_success_screen():
	if (result_screen == null):
		result_screen = ResultScreen._construct(encounter_data.name, rewards, true)
		add_child(result_screen)
	else:
		result_screen.visible = true
