extends Node

@export var player_node: Node

# Placeholder for sound preloading; replace the paths with your actual sound files.
var pop_sfx = preload("res://sound/sfx/pop_ultimative.mp3")
var woob_bass_sfx = preload("res://sound/sfx/woob_bass.mp3")

func _ready() -> void:
	randomize()  # Initialize the random number generator for pitch variation.
	player_node.connect("node_pressed", Callable(self, "_on_node_pressed"))

func play_sound(sound: AudioStream, delay: float = 0, pitch_shift = 0, volume_shift = 0) -> void:
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	var new_player := AudioStreamPlayer.new()
	new_player.stream = sound
	
	# Randomly alter the pitch between 95% and 105%
	new_player.pitch_scale = randf_range(0.90 + pitch_shift, 1.05 + pitch_shift)
	new_player.volume_db = volume_shift
	add_child(new_player)
	new_player.play()
	new_player.connect("finished", Callable(new_player, "queue_free"))

func _on_node_pressed() -> void:
	play_sound(pop_sfx, 0, -0.3, -1)
	play_sound(woob_bass_sfx, 0, 0.3, -10)
