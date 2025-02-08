extends Control
class_name DebugMenu

@export var selected_node_label : Label
@export var hovered_node_label : Label
@export var mem_label : Label
@export var cpu_label : Label
@export var restart_button : Button

func set_mem(node_name: String) -> void:
	mem_label.text = "MEM: " + node_name

func set_cpu(node_name: String) -> void:
	cpu_label.text = "CPU: " + node_name

func set_select(node_name: String) -> void:
	selected_node_label.text = "Selected Node: " + node_name

func set_hovered(node_name: String) -> void:
	hovered_node_label.text = "Hovered Node: " + node_name

func _ready() -> void:
	restart_button.pressed.connect(_restart_pressed)

func _restart_pressed() -> void:
	FlowSystem._on_change_state(FlowSystem.GameStates.PLAY)
	get_tree().reload_current_scene()
