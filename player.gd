extends Camera3D
class_name Player

var camera_rotation_dir : float
@export var speed : float = 5
@export var zoom_speed: float = 1.5
@export var lerp_zoom_speed: float = 5
@export var lerp_move_speed: float = 2
@export var min_zoom: float = 5.0
@export var max_zoom: float = 35.0
@export var border_x_low : float = -20
@export var border_x_high : float = 20
@export var border_z_low : float = -20
@export var border_z_high : float = 20

var rotating_with_mouse : bool = false
var moving_with_mouse : bool = false
var target_zoom : float
var target_position : Vector3
var debug_menu : DebugMenu
var hovered_node = null
var selected_node
const tooltip_scene : PackedScene = preload("res://ui/scenes/tooltip.tscn")
var tooltip : NodeTooltip

signal node_pressed

@export var cpu : float :
	set (value):
		cpu = max(value, 0)
		if debug_menu: 
			debug_menu.set_cpu(value)
		if (value < 1):
			if tooltip: tooltip.queue_free()
			FlowSystem._on_change_state(FlowSystem.GameStates.OVER)
	get:
		return cpu

@export var mem : float :
	set (value):
		mem = value
		debug_menu.set_mem(value)
		if (value < 1):
			_remove_tooltip()
			FlowSystem._on_change_state(FlowSystem.GameStates.OVER)
			
	get:
		return mem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_zoom = position.y
	debug_menu = get_tree().get_nodes_in_group("debug")[0]
	cpu = 10
	mem = 10
	# var start_node = get_tree().get_nodes_in_group("END")[0]
	# _select_node(start_node)
	var level = get_node("/root/MainLevel")
	level.generation_finished.connect(select_start)

	#print("player_ready")
	
func select_start() -> void:
	var start_node = get_tree().get_nodes_in_group("END")[0] as UebanPoint3D
	_select_node(start_node, false)
	position.x = start_node.position.x
	position.z = start_node.position.z

func _define_vector() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	return Vector3(input_dir.normalized().x, 0, input_dir.normalized().y)

func _process(delta):
	var zoom_coef = max_zoom/target_zoom
	target_position = position + _define_vector()
	target_position.x = clamp(target_position.x, border_x_low * zoom_coef, border_x_high * zoom_coef)
	target_position.z = clamp(target_position.z, border_z_low * zoom_coef, border_z_high * zoom_coef)
	position = lerp(position, target_position, delta * lerp_move_speed)
	position.y = lerp(position.y, target_zoom, lerp_zoom_speed * delta)
	size = position.y
	#rotate_y(camera_rotation_dir * delta * camera_speed)
	_cast()
	
	#print(position)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = max(position.y - zoom_speed, min_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = min(position.y + zoom_speed, max_zoom)
		
		if event.button_index == MOUSE_BUTTON_LEFT && selected_node.linked_instances.has(hovered_node) && event.pressed && hovered_node!=null:
			emit_signal("node_pressed")  # Emit the signal before selecting the node
			_select_node(hovered_node)

func _cast():
		var space = get_world_3d().direct_space_state
		var mousePosViewport = get_viewport().get_mouse_position()
		var rayOrigin = project_ray_origin(mousePosViewport)
		var rayEnd = rayOrigin+project_ray_normal(mousePosViewport)*100
		var detectionParameters = PhysicsRayQueryParameters3D.new() 
		detectionParameters.collide_with_areas = true
		detectionParameters.from = rayOrigin
		detectionParameters.to = rayEnd
	
		var rayArray = space.intersect_ray(detectionParameters)
		if (rayArray.has("collider")):
			hovered_node = rayArray["collider"].get_parent()
			debug_menu.set_hovered(hovered_node.name)
			if !tooltip:
				tooltip = tooltip_scene.instantiate() as NodeTooltip
				add_child(tooltip)
			# if tooltip:
			# 	print("AHUEL")
			if (hovered_node):
				tooltip.update_tooltip(hovered_node)
		else:
			hovered_node = null
			debug_menu.set_hovered("None")
			_remove_tooltip()
		
		#print(hovered_node)
func _select_node(node : UebanPoint3D, callEncounter: bool = true):
		if (selected_node != null):
				selected_node.deselect()
		
		if (node == get_tree().get_nodes_in_group("END")[1]):
			FlowSystem._on_change_state(FlowSystem.GameStates.WIN)
		selected_node = node
		selected_node.select(callEncounter)
		debug_menu.set_select(selected_node.name)
		# cpu += selected_node.my_resource.cpu
		mem += selected_node.my_resource.mem

func _remove_tooltip():
	if tooltip:
				tooltip.call_deferred("queue_free")
				tooltip = null
