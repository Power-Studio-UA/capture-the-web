extends Control
class_name NodeTooltip

@export var name_label : Label
@export var description_label : Label
@export var attitude_label : RichTextLabel
#@export var background : ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_global_mouse_position()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position()
	update_size()

func update_size():
	var content_size = $MarginContainer/VBoxContainer2.get_combined_minimum_size()
    
	 # Adjust background size
	custom_minimum_size = content_size + Vector2(40, 40)  # Padding
	size = custom_minimum_size

func set_attitude(state: UebanPoint3D.NodeType) -> void:
	match state:
		0:
			attitude_label.text = "[color=red]Hostile"
		1:
			attitude_label.text = "[color=green]Loyal"
		2:
			attitude_label.text = "[color=violet]Nemesis"