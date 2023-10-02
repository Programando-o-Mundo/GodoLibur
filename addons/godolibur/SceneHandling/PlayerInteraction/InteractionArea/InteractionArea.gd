extends Area2D
class_name InteractionArea

@export var only_one_direction: bool
@export var vector_direction: Vector2 = Vector2.ZERO

@export_category("Interval")
@export var interaction_have_interval : bool = false
@export_range(0.8,2,0.1) var interval_time_in_seconds : float = 0.8

signal player_interacted(motion)

var disabled := false : set = disable_interaction

func interact(motion: Vector2) -> void:

	if player_is_looking_in_the_right_direction(motion) or disabled:
		return
		
	player_interacted.emit(motion)
	
	if interaction_have_interval:
		
		disabled = true
		
		await get_tree().create_timer(interval_time_in_seconds).timeout
	
		disabled = false

# This methods verify if this node was set to only respond if the player
# is looking at a specific direction, and if the player is looking into 
# this specific direction
func player_is_looking_in_the_right_direction(vector : Vector2) -> bool:
	return only_one_direction and not(vector_direction == vector.normalized())
	
func disable_interaction(value : bool) -> void:
	disabled = value
