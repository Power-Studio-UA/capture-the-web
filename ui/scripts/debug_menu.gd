extends Control
class_name DebugMenu

@export var selected_node_label : Label
@export var hovered_node_label : Label
@export var deck_button : Button
@export var mem_label : ResourceRow
@export var cpu_label : ResourceRow
@export var restart_button : Button
@onready var theme_instance = preload("res://assets/ui_styles/general_ui.tres")
var deck : DeckView

func set_mem(amount: int) -> void:
	mem_label.resource_amount = amount

func set_cpu(amount: int) -> void:
	cpu_label.resource_amount = amount

func set_select(node_name: String) -> void:
	selected_node_label.text = "Selected Node: " + node_name

func set_hovered(node_name: String) -> void:
	hovered_node_label.text = "Hovered Node: " + node_name

func _ready() -> void:
	restart_button.pressed.connect(_restart_pressed)
	deck_button.pressed.connect(_show_deck)
	theme = theme_instance
	# $MarginContainer/VBoxContainer/Main/CentralRow/Profile.visible = false

func _restart_pressed() -> void:
	FlowSystem._on_change_state(FlowSystem.GameStates.PLAY)
	get_tree().reload_current_scene()

func _show_deck():
	var main_level = get_tree().get_first_node_in_group("main") as MainLevel
	var player_data = main_level.player_state
	deck = DeckView._construct()
	for card_id in player_data['deck'].keys():
		var count = player_data['deck'][card_id]
		if card_id in main_level.cards:
			for i in range(count):
				deck._add_card(main_level.cards[card_id])

	add_child(deck)
