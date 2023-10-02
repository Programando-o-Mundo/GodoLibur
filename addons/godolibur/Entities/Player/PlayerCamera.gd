extends Camera2D
class_name PlayerCamera

@export_category("Limits")
@export var topLeftBigger : Marker2D   
@export var bottomRightBigger : Marker2D   
@export var topLeftShorter : Marker2D        
@export var bottomRightShorter : Marker2D    

"""
# In order set a custom limts for the camera
# we use two position nodes, and set the camera limits
# as the positions of the nodes. When using in scene
# we just make edit these nodes to whoever position
"""
func _ready():
	setup_shorter_limits()

func setup_bigger_limits():
	limit_top    = topLeftBigger.position.y
	limit_left   = topLeftBigger.position.x
	limit_bottom = bottomRightBigger.position.y
	limit_right  = bottomRightBigger.position.x

func setup_shorter_limits():
	limit_top    = topLeftShorter.position.y
	limit_left   = topLeftShorter.position.x
	limit_bottom = bottomRightShorter.position.y
	limit_right  = bottomRightShorter.position.x

func activate():
	self.make_current()

