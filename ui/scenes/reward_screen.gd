extends Control

@export var reward_container : HBoxContainer 
@export var return_button : Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# test_spawn()
	return_button.pressed.connect(_close)

func _test_spawn() -> void:
	var obj = ResourceRow.constructor(15, ResourceIcon.Ingame_Resources.MEM)
	reward_container.add_child(obj)
	obj = ResourceRow.constructor(25, ResourceIcon.Ingame_Resources.REP)
	reward_container.add_child(obj)

func _close() -> void:
	self.queue_free()
