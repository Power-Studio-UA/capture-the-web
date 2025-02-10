extends Node3D
class_name MainLevel
#@onready var camera: Camera3D = $Camera3D
#
#@export var focus_distance: float = 5.0
#@export var focus_angle: Vector3 = Vector3(30, 0, 0)
#
#func _input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#var ray_origin = camera.project_ray_origin(event.position)
		#var ray_direction = camera.project_ray_normal(event.position)
		#
		#var space_state = get_world_3d().direct_space_state
		#var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)
		#var result = space_state.intersect_ray(query)
		#
		#if result and result.collider is Node3D:
			#focus_on_node(result.collider)
#
#func focus_on_node(node: Node3D):
	#camera.look_at(node.global_position)
	#camera.global_position = node.global_position - camera.global_transform.basis.z * focus_distance
	#camera.rotation_degrees = focus_angle

signal generation_finished()  # Define a signal with one parameter
const GraphGenerator = preload("res://graph_generator.gd")
const packedNode = preload("res://modules/Node.tscn")
#var NodeScene = preload("res://modules/Node.tscn")
#var LineScene = preload("res://modules/Line.tscn")
#
#const encounter_json = preload("res://configs/encounters.json")
#const battles_json = preload("res://configs/battles.json")
#const card_sets_json = preload("res://configs/card_sets.json")

var encounters = {}
var battles = {}
var card_sets = {}
var cards = {}
var player_state = {}

# TODO remove it's hardcoded
var encounter_id = "3ca71814-c226-443b-bd35-364358cc3828"
var player_id = "48655b98-8fee-4699-8fc2-38901ce4d70a"


func load_game_data():
	var file = FileAccess.open("res://configs/encounters.json", FileAccess.READ)
	self.encounters = JSON.parse_string(file.get_as_text())
	file.close()

	file = FileAccess.open("res://configs/battles.json", FileAccess.READ)
	self.battles = JSON.parse_string(file.get_as_text())
	file.close()

	file = FileAccess.open("res://configs/card_sets.json", FileAccess.READ)
	self.card_sets = JSON.parse_string(file.get_as_text())
	file.close()

	file = FileAccess.open("res://configs/cards.json", FileAccess.READ)
	self.cards = JSON.parse_string(file.get_as_text())
	file.close()
	
	file = FileAccess.open("res://configs/player.json", FileAccess.READ)
	self.player_state = JSON.parse_string(file.get_as_text())[player_id]
	file.close()

func load_graph(filename: String, descriptions_url: String):
	var config_callback: Callable = func(): 
		return {"player_state": self.player_state, "cards": self.cards, "battles": self.battles}
		
	var file = FileAccess.open(filename, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var graph_data = JSON.parse_string(json_string)
	
	file = FileAccess.open(descriptions_url, FileAccess.READ)
	json_string = file.get_as_text()
	file.close()
	
	var description_data = JSON.parse_string(json_string)
	
	var node_instances = {}
	for index in graph_data["points"].size():
		var point_data = graph_data["points"][index]
		var node_instance = packedNode.instantiate()
		node_instance.position = Vector3(point_data.x/250, 0, point_data.y/150)
		node_instance.name = "Node_" + str(index)
		add_child(node_instance)
		node_instances[str(index)] = node_instance
		var description = description_data[point_data["id"]]
		var nodeType
		var rnd = RandomNumberGenerator.new()
		if index == 0 || index == graph_data["points"].size() -1:
			nodeType = node_instance.NodeType.values()[2]
		else:
			nodeType = node_instance.NodeType.values()[rnd.randi_range(0, 1)]
		node_instance.setup(
			point_data["id"], 
			description["name"], 
			description["description"], 
			[], 
			preload('res://ui/scenes/encounter.tscn')
				.instantiate().setup(encounters[encounters.keys().pick_random()], config_callback),
			#NewEncounter.new().setup(encounters[encounter_id]),
			nodeType, 
			)

	
	for key in node_instances:
		var new_list = []
		for item in graph_data["graph"][key]:
			new_list.append(node_instances[str(item)])
#
		node_instances[key].linked_instances = new_list
	#for path in graph_data["paths"]:
		#for node_index in path:
			#var node = node_instances[str(node_index)]
			#node.setup(node.NodeType.PATH)

	# Create connections

	for node_index in graph_data["graph"]:
		var current_node = node_instances[str(node_index)]
		for connected_index in graph_data["graph"][node_index]:
			var connected_node = node_instances[str(connected_index)]
			var line = UebanLine3D.new()
			line.start_point = current_node.position
			line.end_point = connected_node.position
			
			# Check if this connection is part of any path
			#var is_path_connection = false
			#for path in graph_data["paths"]:
				#for i in range(path.size() - 1):
					#if (path[i] == int(node_index) and path[i+1] == connected_index) or \
					   #(path[i] == connected_index and path[i+1] == int(node_index)):
						#is_path_connection = true
						#break
				#if is_path_connection:
					#break
			
			#line.setup(line.LineType.PATH if is_path_connection else line.LineType.DEFAULT)
			line.setup(line.LineType.DEFAULT)
			add_child(line)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var generator = GraphGenerator.new()
	
	# Generate a graph
	var urls = generator.generate_graph()
	load_game_data()
	load_graph(urls[0], urls[1])
	generation_finished.emit()
	#upd_reps(5)
	#var file = FileAccess.open(graph_url, FileAccess.READ)
	#var data = JSON.parse_string(file.get_as_text())
	#
	pass # Replace with function body.

func add_card_to_deck(card_id)	:
	if player_state.deck.has(card_id):
		player_state.deck[card_id]+=1
	else:
		player_state.deck[card_id] = 1

#func upd_reps(num_reps):
	#rep_upd.emit(num_reps)

# Called every frame. 'delta' is the elapsed time since the previous frame
