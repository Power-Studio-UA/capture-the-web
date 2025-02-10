extends Button

# Called when the node enters the scene tree for the first time.

@export var _sfx : AudioStreamMP3

func _ready() -> void:
	if not _sfx:
		_sfx = preload("res://sound/sfx/reveal.mp3")
	pressed.connect(_on_node_pressed)

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
	play_sound(_sfx, 0, -0.3, -4)
