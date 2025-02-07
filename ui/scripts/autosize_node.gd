extends Control
class_name AutoSize_node

@export var padding: Vector2 = Vector2(10, 10)  

func _ready():
    UpdateSize()
    
func UpdateSize():
    var new_size = Vector2.ZERO  

    for child in get_children():
        if child is Control:
            var child_rect = child.size
            new_size.x = max(new_size.x, child.position.x + child_rect.x)
            new_size.y = max(new_size.y, child.position.y + child_rect.y)
    
    size = new_size + padding 


