class_name IDVector2

const uuid_util = preload('res://addons/uuid/uuid.gd')

@export var x: float
@export var y: float
@export var id: String

func _init(x: float = 0, y: float = 0):
	self.x = x
	self.y = y 
	self.id = uuid_util.v4()
