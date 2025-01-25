extends Control
class_name NodeTooltip

@export var name_label : Label
@export var description_label : Label
@export var background : ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_global_mouse_position()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position()
	update_size()

func update_size():
	var content_size = $MarginContainer/VBoxContainer.get_combined_minimum_size()
    
	 # Adjust background size
	background.custom_minimum_size = content_size + Vector2(20, 20)  # Padding
	background.size = background.custom_minimum_size