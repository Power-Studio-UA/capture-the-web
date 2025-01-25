extends Control
class_name DebugMenu

var selected_node_label : Label
var hovered_node_label : Label
func _ready() -> void:
	selected_node_label = $VBoxContainer/SelectedNode
	hovered_node_label = $VBoxContainer/HoveredNode


func set_select(node_name: String) -> void:
	selected_node_label.text = "Hovered Node: " + node_name

func set_hovered(node_name: String) -> void:
	hovered_node_label.text = "Selected Node: " + node_name