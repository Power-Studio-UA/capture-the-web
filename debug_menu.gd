extends Control
class_name DebugMenu
var label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $Node_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_node_name(name: String) -> void:
	label.text = name