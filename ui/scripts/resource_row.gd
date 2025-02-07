extends Control
class_name  ResourceRow
@export var resource_amount : int
@export var resource_type : ResourceIcon.Ingame_Resources
@export var image : ResourceIcon
@export var text_label : RichTextLabel
const self_scene = preload("res://ui/scenes/resource_row.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_resource(resource_amount, resource_type)

func _update_resource(amount : int, type : ResourceIcon.Ingame_Resources) -> void:
	resource_amount = amount
	resource_type = type
	text_label.text = str(resource_amount)
	image.selected_res = resource_type

static func constructor(amount : int, type : ResourceIcon.Ingame_Resources)-> ResourceRow:
	var obj = self_scene.instantiate()
	obj._update_resource(amount, type)
	return obj