extends Control
class_name DebugMenu

@export var selected_node_label : Label
@export var hovered_node_label : Label
@export var mem_label : RichTextLabel
@export var cpu_label : RichTextLabel
@export var restart_button : Button
@onready var theme_instance = preload("res://assets/ui_styles/general_ui.tres")

func set_mem(node_name: String) -> void:
	mem_label.text = "[b]" + node_name + "[/b] MEM"

func set_cpu(node_name: String) -> void:
	cpu_label.text = "[b]" + node_name + "[/b] CPU"

func set_select(node_name: String) -> void:
	selected_node_label.text = "Selected Node: " + node_name

func set_hovered(node_name: String) -> void:
	hovered_node_label.text = "Hovered Node: " + node_name

func _ready() -> void:
	restart_button.pressed.connect(_restart_pressed)
	theme = theme_instance
	# $MarginContainer/VBoxContainer/Main/CentralRow/Profile.visible = false

func _restart_pressed() -> void:
	FlowSystem._on_change_state(FlowSystem.GameStates.PLAY)
	get_tree().reload_current_scene()