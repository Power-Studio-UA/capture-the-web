extends Node3D
class_name UebanLine3D

enum LineType { DEFAULT, PATH }

var start_point: Vector3
var end_point: Vector3
var radius: float = 0.01  # Default radius, can be adjusted

@export var gas: float

func setup(type: LineType = LineType.DEFAULT, gas_value: float = 1.0):
	self.gas = gas_value
	var material = StandardMaterial3D.new()
	
	match type:
		LineType.DEFAULT:
			material.albedo_color = Color(0.3, 0.3, 0.3)  # Dark Gray
		LineType.PATH:
			material.albedo_color = Color(1, 0, 0)  # Red
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Calculate the height of the cylinder based on the distance between start and end points
	var height = start_point.distance_to(end_point)
	
	# Create a cylinder mesh
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = radius
	cylinder_mesh.bottom_radius = radius
	cylinder_mesh.height = height
	
	# Create a mesh instance and assign the cylinder mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = cylinder_mesh
	mesh_instance.material_override = material
	
	# Position the cylinder between the start and end points
	var direction = (end_point - start_point).normalized()
	var midpoint = (start_point + end_point) / 2.0
	mesh_instance.transform.origin = midpoint
	
	# Rotate the cylinder to align with the direction vector
	var up_vector = Vector3(0, 1, 0)
	var rotation_axis = up_vector.cross(direction).normalized()
	var rotation_angle = acos(up_vector.dot(direction))
	mesh_instance.rotate(rotation_axis, rotation_angle)
	
	add_child(mesh_instance)
