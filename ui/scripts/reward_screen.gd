extends Control
class_name ResultScreen

@export var reward_container : HBoxContainer 
@export var return_button : Button
@export var battle_state : RichTextLabel
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

func _set_battle_state(isWin : bool):
	if isWin:
		battle_state.text = "[center] Battle Status:[p][center][color=green][b]WIN"
	else:
		battle_state.text = "[center] Battle Status:[p][center][color=red][b]LOST"

func _set_rewards(rewards_dictionary : Dictionary):
	for child in reward_container.get_children():
		reward_container.remove_child(child)
	for reward in rewards_dictionary.keys():
		reward_container.add_child(ResourceRow.constructor(rewards_dictionary[reward], reward))
