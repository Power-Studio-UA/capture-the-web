extends MeshInstance3D
class_name NodeVisuals

enum NodeVisualType {
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

@export var downscaler = 10
var is_available = false
var is_selected = false
var is_hovered = false
var risk_level = 0.0
var node_type: NodeVisualType = NodeVisualType.NONE

var desired_custom_color: Color = Color(0.0, 0.0, 0.0)
var shared_material = load("res://visuals/Node/node_shader.tres")
var material

# Animation flags
var color_animation_active = false
var height_animation_active = false
var outline_animation_active = false

# Animation threshold
const ANIMATION_THRESHOLD = 0.005

func _ready():
	var unique_material = shared_material.duplicate(true)
	set_surface_override_material(0, unique_material)
	material = get_surface_override_material(0)
	material.get_next_pass().set_shader_parameter("outline_width", 0.0)
	material.set_shader_parameter("custom_color", Color(0.0, 0.0, 0.0))
	
func change_node_visuals(new_type = null, new_is_available = null, new_is_selected = null):
	if new_type:
		set_node_type(new_type)
	if new_is_available != null:
		is_available = new_is_available
	if new_is_selected != null:
		is_selected = new_is_selected
	
func set_node_type(new_node_type: NodeVisualType):
	node_type = new_node_type
	desired_custom_color = Color(0.0, 0.0, 0.0)
	risk_level = material.get_shader_parameter("risk_level")
	match node_type:
		NodeVisualType.LOW_RISK:
			print("LOW")
			is_available = true
			desired_custom_color = Color(0.0, 0.545, 0.105)
			set_risk_level(-1.0)
		NodeVisualType.HIGH_RISK:
			print("HIGH")
			is_available = true
			desired_custom_color = Color(0.5, 0.1, 0.0)
			set_risk_level(1.0)
		NodeVisualType.VISITED:
			desired_custom_color = Color(0.5, 0.42, 0.55)
			is_selected = false
			is_available = false
		NodeVisualType.SELECTED:
			desired_custom_color = Color(0.9, 0.9, 0.9)
			is_selected = true
			is_available = true
		NodeVisualType.UNVISITED:
			desired_custom_color = Color(0.5, 0.5, 0.5)
			is_available = false
			is_selected = false
		NodeVisualType.SPECIAL:
			is_selected = true
			is_available = true
			desired_custom_color = Color(0.25, 0.5, 1.5)
		NodeVisualType.START:
			desired_custom_color = Color(0.9, 0.9, 0.9)
		NodeVisualType.FINISH:
			is_selected = true
			desired_custom_color = Color(2.05, 1.5, 0.5)
		_:
			print("Unknown node type.")
	
	# Reset animation flags
	color_animation_active = true
	height_animation_active = true
	outline_animation_active = true
	
func _physics_process(delta: float) -> void:
	set_outline_width((9 if is_selected else 3 if is_available else 0) + (3 if is_hovered else 0), delta)
	update_custom_color(delta)
	update_height(delta)
	
func set_available(val: bool = true):
	is_available = val
	
func set_selected(val: bool = true):
	is_selected = val
	
func set_risk_level(val: float):
	risk_level = val
	material.set_shader_parameter("risk_level", risk_level)
	
func update_height(delta = 1, speed = 100):
	var target_height = 0.0 if node_type != NodeVisualType.UNVISITED else -0.75/downscaler
	var current_height = global_position.y
	var new_height = animate_value_change(current_height, target_height, delta, 50, 0)
	
	# Stop height animation if close to target
	if abs(new_height - target_height) <= ANIMATION_THRESHOLD:
		new_height = target_height
		height_animation_active = false
	
	global_position = Vector3(global_position.x, new_height, global_position.z)
	
func update_custom_color(delta = 1, speed = 100):
	var current_custom_color: Color = material.get_shader_parameter("custom_color")
	var new_r = animate_value_change(current_custom_color.r, desired_custom_color.r, delta, speed, 0)
	var new_g = animate_value_change(current_custom_color.g, desired_custom_color.g, delta, speed, 0)
	var new_b = animate_value_change(current_custom_color.b, desired_custom_color.b, delta, speed, 0)
	
	# Stop color animation if components are close to target
	if (abs(new_r - desired_custom_color.r) <= ANIMATION_THRESHOLD and 
		abs(new_g - desired_custom_color.g) <= ANIMATION_THRESHOLD and 
		abs(new_b - desired_custom_color.b) <= ANIMATION_THRESHOLD):
		new_r = desired_custom_color.r
		new_g = desired_custom_color.g
		new_b = desired_custom_color.b
		color_animation_active = false
	
	material.set_shader_parameter("custom_color", Color(new_r, new_g, new_b))
	
func animate_value_change(from, to, delta = 1, speed = 300, margin = 1):
	var vector = to - from - margin
	return from + (speed * vector / (abs(vector) + 2.5) / (abs(vector) + 5) * delta)
	
func set_outline_width(val: float = 0, delta = 1):	 # [0; 4]
	var current_outline = material.get_next_pass().get_shader_parameter("outline_width")
	var new_outline = animate_value_change(current_outline, val, delta)
	
	# Stop outline animation if close to target
	if abs(new_outline - val) <= ANIMATION_THRESHOLD:
		new_outline = val
		outline_animation_active = false
	
	material.get_next_pass().set_shader_parameter("outline_width", new_outline)

# Optional: Check if all animations are complete
func are_animations_complete() -> bool:
	return not (color_animation_active or height_animation_active or outline_animation_active)
