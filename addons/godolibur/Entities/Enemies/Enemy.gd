extends CharacterBody2D
class_name Enemy

signal remove_enemy(enemy)
signal enemy_moved(motion)

@export var max_speed := 135

@export_category("Pathfinding settings")
@export_enum("Idle", "Physics") var pathfinding_process_callback : String = "Idle" ## Determines weather the processing of elapsed time is calculated during process(_process) or during physics frames(_physics_process)
@export_range(0.05,1.0,0.01) var update_pathfinding_wait_time := 0.2
@export var pathfinding : NavigationAgent2D

@export_category("Player")
@export var player_collider : Area2D
@export var player : CharacterBody2D

var time_accumulator := 0.0
var __process_time_in_the_physics_engine := false

var enemy_ready = false
var current_target 
	
func _ready():
	call_deferred("enemy_setup")
	
func enemy_setup() -> void:
	
	if enemy_ready:
		return
	
	await get_tree().physics_frame
	
	var entities = get_parent()
	if entities is Entities:
		player = entities.player
	
	if player == null:
		printerr("ERROR! Player not found!")
	else:
		current_target = player.position
		pathfinding.set_target_position(current_target)
		
	if player_collider:
		player_collider.body_entered.connect(_on_player_entered)
		
	if pathfinding_process_callback == "Physics":
		__process_time_in_the_physics_engine = true
		
	enemy_ready = true

func _process(delta: float) -> void:
	time_accumulator += (delta * int(not __process_time_in_the_physics_engine))
	
func _physics_process(delta: float) -> void:
	time_accumulator += (delta * int(__process_time_in_the_physics_engine))
	
	if time_accumulator >= update_pathfinding_wait_time:
		update_pathfinding()

	if pathfinding.is_navigation_finished():
		return
		
	var cur_agent_position : Vector2 = global_position 
	var next_path_position : Vector2 = pathfinding.get_next_path_position()
	
	var new_velocity : Vector2 = next_path_position - cur_agent_position 
	new_velocity = new_velocity.normalized() * max_speed
	
	enemy_moved.emit(new_velocity)
	
	velocity = new_velocity
	move_and_slide()
	
func switch_physics_and_motion(value: bool) -> void:
	set_physics_process(value)

func update_pathfinding():
	if player.position != current_target:
		current_target = player.position
		pathfinding.set_target_position(current_target)
		
	time_accumulator = 0.0

func _on_player_entered(_body : Node2D) -> void:
	CampaingOverseer.current_campaing.game_over()
