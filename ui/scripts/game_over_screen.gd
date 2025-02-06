extends Control

@export var head_label: Label
@export var description_label: RichTextLabel
@export var restart_button: Button
@export_multiline var win_description := ""
@export_multiline var lose_description : =""
var description: String :
    set(value):
        description = value
    get:
        match FlowSystem.current_state:
            FlowSystem.GameStates.WIN:
                description = win_description
            FlowSystem.GameStates.OVER:
                description = lose_description
        return description


@export var win_header : String
@export var lose_header : String
var header: String :
    set(value):
        header = value
    get:
        print(FlowSystem.current_state)
        match FlowSystem.current_state:
            FlowSystem.GameStates.WIN:
                header = win_header
            FlowSystem.GameStates.OVER:
                header = lose_header
        return header
    
        
func _ready() -> void:
    restart_button.pressed.connect(_restart_pressed)

func _restart_pressed() -> void:
    print("pressed")
    FlowSystem._on_change_state(FlowSystem.GameStates.PLAY)
    get_tree().reload_current_scene()

func _appear() -> void:
    var debug_menu = get_tree().get_nodes_in_group("debug")[0]
    debug_menu.call_deferred("queue_free")
    head_label.text = header
    description_label.text = description
    visible = true
    get_tree().paused = true
