extends CharacterBody2D
class_name Movable

signal cant_move()

# You can force the object to be pushed only in one direction, or you can allow it
# to be pushed in all directions, taking into account the player's movement
enum PushDirection {
	Left,
	Right,
	Up,
	Down,
	All
}

const direction_vectors = {
	PushDirection.Left : Vector2.LEFT,
	PushDirection.Right : Vector2.RIGHT,
	PushDirection.Up : Vector2.UP,
	PushDirection.Down : Vector2.DOWN
}

@export var interaction_area : InteractionArea 
@export_range(0.0,2.0,0.1) var sliding_time := 1.2 # Total time between the start and beginning of animation
@export var one_shot := false # One shot means that an object can only be pushed once

@export_category("Push")

@export var push_direction := PushDirection.All # Push direction of the object
@export var distance_per_push := 15 # Total distance between each push


# verify if the current object is moving or not
var sliding := false
# Check wether the object was already moved once
var moved_at_least_once := false 
var can_collide := true

@onready var collision : CollisionShape2D = $Collision

func _ready():
	
	if interaction_area:
		interaction_area.player_interacted.connect(move_object)

# Upon being interacted by the player, this function will be responsible
# to push the object, taking to account the objects PushDirection and the 
# applied motion by the player
func move_object(motion : Vector2) -> void:
	
	if not can_be_interacted():
		return
	
	# Calculate the motion of the movement of the object
	if push_direction != PushDirection.All:
		motion = direction_vectors[push_direction] * distance_per_push
	else:
		motion = motion.normalized() * distance_per_push
	
	# For the interpolation to occur, the destination vector must be the 
	# current global_position of the object + the motion applied to it
	var destination = global_position + motion
	
	if can_move(destination):

		# Call the tween node to interpolate(animate) the object
		# to it's new position
		var tween = create_tween()
		tween.tween_property(
			self,
			"global_position",
			destination,
			sliding_time,
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		tween.play()
		sliding = true 
		
		await tween.finished
		
		sliding = false
		moved_at_least_once = true
		
	else:
		cant_move.emit()


func can_be_interacted():
	
	if one_shot and moved_at_least_once:
		return false
	
	return not sliding and can_collide

# Verify if the object can be moved, given it's applied force
func can_move(move_to : Vector2) -> bool:
	var future_transform = Transform2D(transform)
	future_transform.origin = move_to
	return not test_move(future_transform,Vector2())
	
func set_collision(value: bool) -> void:
	
	can_collide = value
	
	self.set_collision_layer_value(1,value)
	self.set_collision_mask_value(1,value)
