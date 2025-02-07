extends Panel
class_name ResourceIcon

enum Ingame_Resources {MEM = 0, REP = 1, PATIENCE = 2, INT = 3} 
@export var array : Array[String]
@export var selected_res : Ingame_Resources :
	set(value):
		selected_res = value
		_update_image()
var image : TextureRect 

#Dictionary assets = {Ingame_Resources.MEM : "assets\textures\ram.png"}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_image()


func _update_image() -> void:
	image = $TextureRect
	var index = selected_res
	if (array.size() > index):
		image.texture = load("res://assets/textures/" + array[index])

