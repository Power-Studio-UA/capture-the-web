extends Control
class_name ResultScreen

@export var reward_container : HBoxContainer 
@export var return_button : Button
@export var battle_state : RichTextLabel
@export var name_label : Label
var current_rewards

const self_scene : PackedScene = preload("res://ui/scenes/Reward_screen.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# test_spawn()
	return_button.pressed.connect(_close)

# func _test_spawn() -> void:
# 	var obj = ResourceRow.constructor(15, ResourceRow.Ingame_Resources.MEM)
# 	reward_container.add_child(obj)
# 	obj = ResourceRow.constructor(25, ResourceRow.Ingame_Resources.REP)
# 	reward_container.add_child(obj)

func _close() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	for reward in current_rewards.keys():
		if reward == ResourceRow.Ingame_Resources.MEM:
			player.mem+=current_rewards[reward]
		elif reward == ResourceRow.Ingame_Resources.REP:
			player.cpu+=current_rewards[reward]
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

static func _construct(encounter_name : String, rewards, result : bool) -> ResultScreen:
		var obj = self_scene.instantiate()
		obj.name_label.text = encounter_name + " RESULT"
		obj._set_rewards(rewards)
		obj._set_battle_state(result)
		obj.current_rewards = rewards
		return obj
	
