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

@export var downscaler: int = 10

# State flags
var is_available: bool = false
var is_selected: bool = false
var is_hovered: bool = false
var node_type: NodeVisualType = NodeVisualType.NONE

# The desired color we want to animate to.
var desired_custom_color: Color = Color(0, 0, 0)

# Shared material reference (if needed)
var material

# Animation settings (in seconds)
const COLOR_ANIMATION_DURATION: float = 0.5
const HEIGHT_ANIMATION_DURATION: float = 0.5
const OUTLINE_ANIMATION_DURATION: float = 0.5

# Threshold to decide when an animated value is "close enough" to the target.
const ANIMATION_THRESHOLD: float = 0.001

func _ready() -> void:
	# Get the material (assuming it's already set in the editor)
	material = get_surface_override_material(0)
	# Optionally initialize with a default node type.
	# set_node_type(NodeVisualType.UNVISITED)

func initialize() -> void:
	# Called from node.gd if further initialization is needed.
	pass

func set_node_type(new_node_type: NodeVisualType) -> void:
	node_type = new_node_type
	
	# Set desired color and flags based on state.
	match node_type:
		NodeVisualType.LOW_RISK:
			is_available = true
			desired_custom_color = Color(0.0, 0.545, 0.105)  # low risk
		NodeVisualType.HIGH_RISK:
			is_available = true
			desired_custom_color = Color(0.5, 0.1, 0.0)  # high risk
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
			push_error("Unknown node type.")
	
	# Start all animations.
	animate_changes()

func animate_changes() -> void:
	animate_color(COLOR_ANIMATION_DURATION)
	animate_height(HEIGHT_ANIMATION_DURATION)
	animate_outline(OUTLINE_ANIMATION_DURATION)

func animate_color(duration: float) -> void:
	var time_passed: float = 0.0
	while time_passed < duration:
		# Get the current color from the mesh's vertex colors.
		var current_color: Color = _get_first_vertex_color(get_mesh())
		# Animate each channel using animate_value_change() with speed = 30.
		var new_r = animate_value_change(current_color.r, desired_custom_color.r, 0.016, 30)
		var new_g = animate_value_change(current_color.g, desired_custom_color.g, 0.016, 30)
		var new_b = animate_value_change(current_color.b, desired_custom_color.b, 0.016, 30)
		var new_color: Color = Color(new_r, new_g, new_b, 1.0)
		_update_all_vertex_colors(new_color)
		# Optional debug:
		# print("Animating color: t =", time_passed, " new_color =", new_color)
		await get_tree().create_timer(0.016).timeout
		time_passed += 0.016
	_update_all_vertex_colors(desired_custom_color)

func animate_height(duration: float) -> void:
	var target_height: float = 0.0
	if node_type == NodeVisualType.UNVISITED:
		target_height = -0.75 / downscaler
	
	var time_passed: float = 0.0
	while time_passed < duration:
		var new_height = animate_value_change(global_position.y, target_height, 0.016, 20)
		# Optional debug:
		# print("Animating height: t =", time_passed, " new_height =", new_height)
		if abs(new_height - target_height) <= ANIMATION_THRESHOLD:
			global_position.y = target_height
			break
		global_position.y = new_height
		await get_tree().create_timer(0.016).timeout
		time_passed += 0.016
	global_position.y = target_height

func animate_outline(duration: float) -> void:
	# Ensure there is an Outline child node.
	if not has_node("Outline"):
		push_error("Outline node not found!")
		return
	var outline_node = $Outline
	
	# Compute an outline "value" based on state:
	#   - 9 if selected, else 3 if available, else 0.
	#   - Add 3 if hovered.
	var base_value: float = 0.0
	if is_selected:
		base_value = 8.0
	elif is_available:
		base_value = 3.5
	else:
		base_value = 0.0
	if is_hovered:
		base_value += 3.0
	
	# Map the outline value (0 to 12) to an additional scale factor (0 to 0.3)
	# using a fixed base scale of 0.95 (outline deactivated).
	var additional_factor = (base_value / 6.0) * 0.3
	var target_scale_factor = 0.95 + additional_factor
	# Use a uniform scale since the scale is relative.
	var target_scale = Vector3(target_scale_factor, target_scale_factor, target_scale_factor)
	
	# Optional debug:
	# print("Animating outline: base_value =", base_value, " target_scale =", target_scale)
	
	var time_passed: float = 0.0
	while time_passed < duration:
		var current_scale: Vector3 = outline_node.scale
		var new_x = animate_value_change(current_scale.x, target_scale.x, 0.016, 30)
		var new_y = animate_value_change(current_scale.y, target_scale.y, 0.016, 30)
		var new_z = animate_value_change(current_scale.z, target_scale.z, 0.016, 30)
		var new_scale = Vector3(new_x, new_y, new_z)
		outline_node.scale = new_scale
		# Optional debug:
		# print("Animating outline: t =", time_passed, " new_scale =", new_scale)
		if abs(new_x - target_scale.x) <= ANIMATION_THRESHOLD and abs(new_y - target_scale.y) <= ANIMATION_THRESHOLD and abs(new_z - target_scale.z) <= ANIMATION_THRESHOLD:
			outline_node.scale = target_scale
			break
		await get_tree().create_timer(0.016).timeout
		time_passed += 0.016
	outline_node.scale = target_scale

func _update_all_vertex_colors(new_color: Color) -> void:
	# Force alpha to 1.0.
	var forced_color = Color(new_color.r, new_color.g, new_color.b, 1.0)
	change_vertex_colors(forced_color)

func _get_first_vertex_color(mesh: Mesh) -> Color:
	var arrays = mesh.surface_get_arrays(0)
	if arrays.is_empty():
		return Color.BLUE_VIOLET  # Fallback for debugging.
	var colors = arrays[Mesh.ARRAY_COLOR]
	if colors and colors.size() > 0:
		return colors[0]
	return Color.BLUE_VIOLET

func change_vertex_colors(new_color: Color) -> void:
	var mesh = get_mesh()
	if mesh == null:
		return
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Get mesh arrays.
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	var uvs = arrays[Mesh.ARRAY_TEX_UV]
	var indices = arrays[Mesh.ARRAY_INDEX]
	
	# Rebuild the mesh with the new color.
	for i in range(vertices.size()):
		st.set_color(new_color)
		st.set_normal(normals[i])
		if uvs and uvs.size() > i:
			st.set_uv(uvs[i])
		st.add_vertex(vertices[i])
	
	# Add indices if they exist.
	if indices:
		for index in indices:
			st.add_index(index)
	
	var new_mesh = st.commit()
	set_mesh(new_mesh)

func initialize_vertex_colors(initial_color: Color) -> void:
	_update_all_vertex_colors(initial_color)

#----------------------------------------------------------------------------
# Custom animation function used throughout.
# It now has an internal 'quadratic' flag that, when true, uses a quadratic (ease-out) interpolation.
# (The 'quadratic' flag is set internally and is not passed by the caller.)
func animate_value_change(from, to, delta = 1, speed = 300, margin = ANIMATION_THRESHOLD):
	# Toggle this flag here to switch between quadratic easing and the original method.
	var quadratic = true
	
	if quadratic:
		# Use a constant divisor to slow down the per-frame step.
		const QUAD_DIVISOR = 5.0
		var p = (speed * delta) / QUAD_DIVISOR
		p = clamp(p, 0, 1)
		# Ease-out quadratic: f(t) = 1 - (1 - t)^2.
		var t = 1 - pow(1 - p, 2)
		return from + (to - from) * t
	else:
		var vector = to - from - margin
		return from + (speed * vector / (abs(vector) + 2.5) / (abs(vector) + 5) * delta)
