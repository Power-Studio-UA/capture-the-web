extends MeshInstance3D

enum NodeType {
	LOW_RISK,
	HIGH_RISK,
	VISITED,
	UNVISITED,
	SPECIAL,
	SELECTED,
	START,
	FINISH,
	NONE
}

var is_avaliable = false
var is_selected = true
var risk_level = 1.0
var node_type: NodeType = NodeType.NONE
var desired_custom_color: Color = Color(0.0, 0.0, 0.0)

var shared_material = load("res://visuals/Node/node_shader.tres")
var material

func _ready():
	var unique_material = shared_material.duplicate(true)
	set_surface_override_material(0, unique_material)
	material = get_surface_override_material(0)
	set_node_type(NodeType.HIGH_RISK)
	material.get_next_pass().set_shader_parameter("outline_width", 0.0)
	material.set_shader_parameter("custom_color", Color(0.0, 0.0, 0.0))
	
func change_node_visual(new_is_avaliable = null, new_is_selected = null, new_type = null):
	if new_type:
		set_node_type(new_type)
	if new_is_avaliable:
		is_avaliable = new_is_avaliable
	if new_is_selected:
		is_selected = new_is_selected
	
func set_node_type(new_node_type: NodeType = NodeType.LOW_RISK):
	node_type = new_node_type
	var custom_color = Color(0.0, 0.0, 0.0)
	risk_level = material.get_shader_parameter("risk_level")
	match node_type:
		NodeType.LOW_RISK:
			set_risk_level(-1.0)
		NodeType.HIGH_RISK:
			set_risk_level(1.0)
		NodeType.VISITED:
			desired_custom_color = Color(0.5, 0.42, 0.69)
		NodeType.UNVISITED:
			desired_custom_color = Color(0.5, 0.5, 0.5)
		NodeType.SPECIAL:
			desired_custom_color = Color(0.25, 0.5, 1.5)
		NodeType.START:
			desired_custom_color = Color(0.9, 0.9, 0.9)
		NodeType.FINISH:
			desired_custom_color = Color(2.05, 1.5, 0.5)
		_:
			print("Unknown node type.")
	
func _physics_process(delta: float) -> void:
	set_outline_width(8 if is_selected else 3 if is_avaliable else 0, delta)
	update_custom_color(delta)
	update_height(delta)
	
func set_avaliable(val: bool = true):
	is_avaliable = val
	
func set_selected(val: bool = true):
	is_selected = val
	
func set_risk_level(val: bool = true):
	risk_level = val
	material.set_shader_parameter("risk_level", risk_level)
	
func update_height(delta = 1, speed = 100):
	var target_height = 0.0 if node_type != NodeType.UNVISITED else -0.75
	global_position = Vector3(global_position.x, animate_value_change(global_position.y, target_height, delta, 50, 0), global_position.z)
		
	
func update_custom_color(delta = 1, speed = 100):
	var current_custom_color: Color = material.get_shader_parameter("custom_color")
	var new_r = animate_value_change(current_custom_color.r, desired_custom_color.r, delta, speed, 0)
	var new_g = animate_value_change(current_custom_color.g, desired_custom_color.g, delta, speed, 0)
	var new_b = animate_value_change(current_custom_color.b, desired_custom_color.b, delta, speed, 0)
	material.set_shader_parameter("custom_color", Color(new_r, new_g, new_b))
	
func animate_value_change(from, to, delta = 1, speed = 300, margin = 1):
	var vector = to - from - margin
	return from + (speed * vector / (abs(vector) + 2.5) / (abs(vector) + 5) * delta)
	
func set_outline_width(val: float = 0, delta = 1):	 # [0; 4]
	var current_outline = material.get_next_pass().get_shader_parameter("outline_width")
	material.get_next_pass().set_shader_parameter("outline_width", animate_value_change(current_outline, val, delta))
