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
var was_selected : bool

var material : StandardMaterial3D
func setup(
	id: String,
	node_name: String,
	node_description: String,
	linked_instances: Array,
	type: NodeType = NodeType.RED):

	self.id = id
	self.node_name = node_name
	self.node_description = node_description
	self.linked_instances = linked_instances

	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	material = StandardMaterial3D.new()
	match type:
		NodeType.RED:
			my_resource = red_resource
		NodeType.GREEN:
			my_resource = green_resource
		NodeType.FINISH:
			my_resource = finish_resource
			add_to_group("END")
			#print("END")
			
	
	material.albedo_color = Color.BLACK
	mesh_instance.material_override = material
	
func select() -> void:
	material.albedo_color = Color.BLUE
	was_selected = true
	for node in linked_instances:
		if !node.was_selected:
			node.material.albedo_color = node.my_resource.material_color

func deselect() -> void:
	material.albedo_color = Color.GRAY
