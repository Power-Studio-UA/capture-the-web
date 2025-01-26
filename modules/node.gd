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

var visited : bool
var node_visuals: NodeVisuals
var node_type: NodeType

func setup(
	id: String,
	node_name: String,
	node_description: String,
	linked_instances: Array,
	type: NodeType):
	
	self.id = id
	self.node_name = node_name
	self.node_description = node_description
	self.linked_instances = linked_instances
	
	# Find the NodeVisuals child node
	node_visuals = $NodeVisualsRoot/NodeMesh
	
	node_visuals.set_node_type(NodeVisuals.NodeVisualType.UNVISITED)
	
	self.node_type = type
	print(node_type)
	
	match type:
		NodeType.RED:
			my_resource = red_resource
		NodeType.GREEN:
			my_resource = green_resource
		NodeType.FINISH:
			my_resource = finish_resource
			add_to_group("END")
			node_visuals.set_node_type(NodeVisuals.NodeVisualType.FINISH)

func select() -> void:
	node_visuals.set_node_type(NodeVisuals.NodeVisualType.SELECTED)
	visited = true
	for node in linked_instances:
		node.node_visuals.is_avaliable = true
		if !node.visited:
			match node.node_type:
				0:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.HIGH_RISK)
					#print("HIGH")
				1:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.LOW_RISK)
					#print("LOW")
				_:
					node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.SPECIAL)
		else:
			node.node_visuals.set_node_type(NodeVisuals.NodeVisualType.VISITED)
			
func deselect() -> void:
	node_visuals.set_node_type(NodeVisuals.NodeVisualType.VISITED)
