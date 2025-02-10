extends Node3D
class_name UebanPoint3D

enum NodeType { RED, GREEN, FINISH }

@export var green_resource : NodeResource
@export var red_resource : NodeResource
@export var finish_resource : NodeResource
@export var id: String
@export var node_name: String
@export var node_description: String
@export var linked_instances: Array
@export var my_resource : NodeResource
@export var encounter : NewEncounter

var visited : bool
var node_visuals: NodeVisuals
var node_type: NodeType

func setup(
	id: String,
	node_name: String,
	node_description: String,
	linked_instances: Array,
	encounter: NewEncounter,
	type: NodeType):
	
	self.id = id
	self.node_name = node_name
	self.node_description = node_description
	self.linked_instances = linked_instances
	self.encounter = encounter

	
	# Find the NodeVisuals child node
	node_visuals = $NodeVisualsRoot/NodeMesh
	
	self.node_type = type
	
	match type:
		NodeType.RED:
			my_resource = red_resource
		NodeType.GREEN:
			my_resource = green_resource
		NodeType.FINISH:
			my_resource = finish_resource
			add_to_group("END")
			node_visuals.set_node_type(NodeVisuals.NodeVisualType.FINISH)

#func setup_encounter() -> Encounter:
	#return Encounter.create

func select(callEncounter : bool = true) -> void:
	node_visuals.set_node_type(NodeVisuals.NodeVisualType.SELECTED)
	visited = true
	for node in linked_instances:
		node.node_visuals.is_available = true
		if !node.visited:

			match node.node_type:
				0:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.HIGH_RISK)
					#print("HIGH")
					if callEncounter:
						self.add_child(encounter)
						encounter.ready()
				1:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.LOW_RISK)
					if callEncounter:
						self.add_child(encounter)
						encounter.ready()
					#print("LOW")
				_:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.SPECIAL)
		else:
			node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.VISITED)
			
func deselect() -> void:
	node_visuals.set_node_type(NodeVisuals.NodeVisualType.VISITED)
