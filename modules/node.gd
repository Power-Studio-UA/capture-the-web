extends Node3D
class_name UebanPoint3D

enum NodeType { DEFAULT, PATH }

@export var health: float
@export var gas: float
@export var id: String
@export var node_name: String
@export var node_description: String
@export var linked_instances: Array

func setup(
	id: String,
	node_name: String,
	node_description: String,
	linked_instances: Array,
	type: NodeType = NodeType.DEFAULT, 
	health_value: float = 10.0, 
	gas_value: float = 10.0):

	self.id = id
	self.node_name = node_name
	self.node_description = node_description
	self.linked_instances = linked_instances
	self.health = health_value
	self.gas = gas_value

	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	var material = StandardMaterial3D.new()
	match type:
		NodeType.DEFAULT:
			material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray
		NodeType.PATH:
			material.albedo_color = Color(1, 0, 0)  # Red
	
	mesh_instance.material_override = material
	
