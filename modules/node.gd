extends Node3D

enum NodeType { DEFAULT, PATH }

func setup(type: NodeType = NodeType.DEFAULT):
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
