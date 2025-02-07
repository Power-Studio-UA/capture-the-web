extends Control
class_name NodeTooltip

@export var name_label : Label
@export var description_label : Label
@export var attitude_label : RichTextLabel
#@export var background : ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_global_mouse_position()
	# update_size()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position()


func set_attitude(state: UebanPoint3D.NodeType) -> void:
	match state:
		0:
			attitude_label.text = "[color=red]Hostile"
		1:
			attitude_label.text = "[color=green]Loyal"
		2:
			attitude_label.text = "[color=violet]Nemesis"

func update_tooltip(node: UebanPoint3D) -> void:
	name_label.text = node.node_name
	description_label.text = node.node_description
	set_attitude(node.node_type)