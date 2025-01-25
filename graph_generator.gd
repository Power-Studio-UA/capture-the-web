extends Node2D

const uuid_util = preload('res://addons/uuid/uuid.gd')
#const IDVector2 = preload("res://modules/IDVector2.gd")

#func _init():
  #print(uuid_util.v4())
#const uuid_util = preload('res://addons/uuid/uuid.gd')
#
#func _init():
  #print(uuid_util.v4())
#class_name GraphGenerator extends Reference
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
var rng = RandomNumberGenerator.new()

#####################
func generate_random_point():
	var random_words = [
		"apple", "banana", "cherry", "dragon", "eagle", 
		"flower", "galaxy", "horizon", "island", "jungle"
		]
	
	var random_sentences = [
		"A lonely traveler seeks adventure.",
		"The wind whispers ancient secrets.",
		"Shadows dance across empty landscapes.",
		"Forgotten memories echo in silent rooms.",
		"Mysterious forces shape unseen worlds." 
		]
	
	return { 
		"gas": randi() % 6 - 5,  # Random int between -5 and 0 
		"hp": randi() % 11 - 5,  # Random int between -5 and 5 
		"name": random_words[randi() % random_words.size()], 
		"description": random_sentences[randi() % random_sentences.size()] 
		}
		
# Function to generate a random convex polygon
func generate_random_convex_polygon(start: Vector2, end: Vector2, num_points: int = 5) -> Array:
	var points = []
	var min_x = min(start.x, end.x)
	var max_x = max(start.x, end.x)
	var min_y = min(start.y, end.y)
	var max_y = max(start.y, end.y)
	
	# Generate random points within the bounding box
	for i in range(num_points):
		var random_x = randf_range(min_x, max_x)
		var random_y = randf_range(min_y, max_y)
		points.append(Vector2(random_x, random_y))
	
	# Compute the convex hull of the points
	points = convex_hull(points)
	
	return points

# Function to compute the convex hull using Andrew's monotone chain algorithm
func convex_hull(points: Array) -> Array:
	if points.size() <= 3:
		return points
	
	# Sort the points lexographically (first by x, then by y)
	points.sort_custom(func(a, b): return a.x < b.x if a.x != b.x else a.y < b.y)
	
	var lower = []
	for point in points:
		while lower.size() >= 2 and cross(lower[lower.size() - 2], lower[lower.size() - 1], point) <= 0:
			lower.pop_back()
		lower.append(point)
	
	var upper = []
	for i in range(points.size() - 1, -1, -1):
		while upper.size() >= 2 and cross(upper[upper.size() - 2], upper[upper.size() - 1], points[i]) <= 0:
			upper.pop_back()
		upper.append(points[i])
	
	lower.pop_back()
	upper.pop_back()
	
	return lower + upper

# Helper function to compute the cross product
func cross(o: Vector2, a: Vector2, b: Vector2) -> float:
	return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)

####################

func generate_graph():
	rng.randomize()
	print("Generating graph")
	var graph = _generate_graph(Vector2(0, 0), Vector2(1000, 600), 100)
	print("Saving graph")
	
	var descriptions = _generate_descrptions(graph["points"])
	var id = uuid_util.v4()
	
	var graph_url = save_graph_to_file(graph, "user://" + id + ".json")
	var description_url = save_graph_to_file(descriptions, "user://" + id + "_descriptions.json")
	
	return [graph_url, description_url]
	
func _generate_descrptions(points: Array) -> Dictionary:
	var result_dict = {}
	for point in points:
		result_dict[point["id"]] = generate_random_point()
	
	return result_dict

func _generate_graph(start: Vector2, end: Vector2, num_points: int) -> Dictionary:
	#var points = poisson_disk_sampling(start, end, num_points)
	
	
	var convex_polygon = generate_random_convex_polygon(start, end, 10)
	var points = poisson_polygon_sampling(
		convex_polygon, 40, 30)
	#points.shuffle()
	#points = points.slice(0, len(points)/2)
	
	points.push_front(start)
	points.push_back(end)
	
	var delaunay_triangulation = Geometry2D.triangulate_delaunay(points)
	var graph = create_graph_from_triangulation(points, delaunay_triangulation)
	
	var paths = []
	var new_graph = graph.duplicate(true)
	for _i in range(1):
		#var path = find_path_bfs(graph, 0, points.size() - 1)
		var path = randomized_path_search(new_graph, 0, points.size() - 1, len(new_graph) * 2)
		paths.append(path)
		#new_graph = remove_random_path_points(new_graph, path)
		new_graph = remove_all_path_points(new_graph, path)
	return {
		"points": points.map(func(p): return {"x": p.x, "y": p.y, "id": uuid_util.v4()}),
		"graph": graph,
		"paths": paths
	}
	
func poisson_polygon_sampling(polygon_points: Array, poisson_radius: float, retries: int) -> Array:
	var packed_vector2_array = PoissonDiscSampling.generate_points_for_polygon(polygon_points, poisson_radius, retries)
	
	var regular_array = [] 
	for vec in packed_vector2_array:
		regular_array.append(vec)
	return regular_array

func poisson_disk_sampling(start: Vector2, end: Vector2, num_points: int) -> Array:
	var points = []
	var width = end.x - start.x
	var height = end.y - start.y
	var min_distance = 50.0
	
	while points.size() < num_points:
		var candidate = Vector2(
			start.x + rng.randf() * width,
			start.y + rng.randf() * height
		)
		
		var is_valid = true
		for point in points:
			if point.distance_to(candidate) < min_distance:
				is_valid = false
				break
		
		if is_valid:
			points.append(candidate)
	
	return points

func create_graph_from_triangulation(points: Array, triangulation: Array) -> Dictionary:
	var graph = {}
	for i in points.size():
		graph[i] = []
	
	for i in range(0, triangulation.size(), 3):
		var a = triangulation[i]
		var b = triangulation[i+1]
		var c = triangulation[i+2]
		
		var rnd_val = rng.randi_range(1, 4)
		
		if rnd_val == 1:
			graph[a].append(b)
			graph[b].append(a)
			
		if rnd_val == 2:
			graph[a].append(c)
			graph[c].append(a)
			
		if rnd_val == 3:
			graph[b].append(c)
			graph[c].append(b)
		
	return graph

func find_path_bfs(graph: Dictionary, start: int, end: int) -> Array:
	var queue = [[start]]
	var visited = {start: true}
	
	while queue:
		var path = queue.pop_front()
		var node = path[-1]
		
		if node == end:
			return path
		
		for neighbor in graph.get(node, []):
			if not visited.has(neighbor):
				visited[neighbor] = true
				var new_path = path.duplicate()
				new_path.append(neighbor)
				queue.append(new_path)
	
	return []
	

func randomized_path_search(graph: Dictionary, start: int, end: int, max_iterations: int = 100) -> Array:
	var current = start
	var path = [current]
	var visited = {start: true}
	
	for _i in range(max_iterations):
		if current == end:
			return path
		
		# Get unvisited neighbors
		var valid_neighbors = []
		for neighbor in graph[current]:
			if not visited.has(neighbor):
				valid_neighbors.append(neighbor)
		
		# If no unvisited neighbors, backtrack
		if valid_neighbors.is_empty():
			path.pop_back()
			if path.is_empty():
				break
			current = path.back()
			continue
		
		# Randomly choose next neighbor
		var next_node = valid_neighbors[rng.randi() % valid_neighbors.size()]
		path.append(next_node)
		visited[next_node] = true
		current = next_node
	
	# If no path found, return partial path
	return path

func find_path(graph: Dictionary, start: int, end: int) -> Array:
	var open_set = []
	var closed_set = []
	var came_from = {}
	var g_score = {}
	var f_score = {}
	
	open_set.append(start)
	g_score[start] = 0
	f_score[start] = 0
	
	while open_set:
		var current = open_set[0]
		if current == end:
			return reconstruct_path(came_from, current)
		
		open_set.erase(current)
		closed_set.append(current)
		
		for neighbor in graph[current]:
			if neighbor in closed_set:
				continue
			
			var tentative_g_score = g_score.get(current, 0) + 1
			
			if neighbor not in open_set:
				open_set.append(neighbor)
			elif tentative_g_score >= g_score.get(neighbor, INF):
				continue
			
			came_from[neighbor] = current
			g_score[neighbor] = tentative_g_score
			f_score[neighbor] = tentative_g_score
	
	return []

func reconstruct_path(came_from: Dictionary, current: int) -> Array:
	var path = [current]
	while current in came_from:
		current = came_from[current]
		path.push_front(current)
	return path

func remove_random_path_points(graph: Dictionary, path: Array) -> Dictionary:
	var modified_graph = graph.duplicate(true)
	var removable_points = path.slice(1, path.size() - 2)
	
	for point in removable_points:
		for key in modified_graph:
			modified_graph[key].erase(point)
		if rng.randf() < 0.5:
			modified_graph.erase(point)
	return modified_graph
	

func remove_all_path_points(graph: Dictionary, path: Array) -> Dictionary:
	var modified_graph = graph.duplicate(true)
	var removable_points = path.slice(1, path.size() - 2)
	
	for point in removable_points:
		for key in modified_graph:
			modified_graph[key].erase(point)
		modified_graph.erase(point)

	return modified_graph

func save_graph_to_file(graph_data: Dictionary, url: String):
	var file = FileAccess.open(url, FileAccess.WRITE)
	file.store_line(JSON.stringify(graph_data, "\t"))
	file.close()
	return url
