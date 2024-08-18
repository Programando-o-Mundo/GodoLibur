extends Node
class_name EnemyController

signal pursuit_started()
signal pursuit_ended()

signal spawn_enemy(enemy, current_location)

"""Defines the amount of time an enemy will pursue the player in seconds"""
@export_range(15,75,0.1) var enemy_pursuit_time_sec := 15

@onready var spawn_timer = $SpawnTimer

@export var pursuit_theme : AudioStream

var in_pursuit := false

var enemies_pursuing := []
var enemies_to_remove := {}
var num_enemies_to_spawn := 0

var timers := []

var current_player_location : String = ""
	
func get_enemies():
	return enemies_pursuing
	
func start_pursuit(enemy_scene: String, starting_scene: String) -> CharacterBody2D:
	
	if in_pursuit:
		return
	
	var timer_index = timers.size()

	
	var enemy_index = enemies_pursuing.size()
	var enemy : Resource = load_enemy(enemy_scene)
	var enemy_instance = enemy.instantiate()
	
	enemies_pursuing.push_back(
		{
		"resource" : enemy, 
		"current_location" : starting_scene,
		"instance" : enemy_instance,
		"active" : true
		}
	)

	if enemy_pursuit_time_sec != -1:
		var enemy_timer = Timer.new()
		timers.push_back(enemy_timer)
		enemy_timer.name = "%s-timer" % "AoOni"
		add_child(enemy_timer)
		
		
		enemy_timer.start(enemy_pursuit_time_sec)
		enemy_timer.timeout.connect(enemy_timer_timeout.bind(enemy_timer, enemy_index, timer_index))
	
	in_pursuit = true
	pursuit_started.emit()
	
	return enemy_instance

func load_enemy(destination_path: String) -> Resource:

	if not ResourceLoader.exists(destination_path):
		printerr("Error! The destination %s provided is not a Scene or does not exist" % destination_path)
		get_tree().quit(1)
	
	var enemy_resource = load(destination_path)
	
	return enemy_resource

"""When the player crosses a new scene"""
func handle_scene_change(new_scene_name: String) -> void:
	
	if in_pursuit:
		var i := 0
		for enemy in enemies_pursuing:
			if not enemy.active or not in_pursuit:
				
				enemy.instance.remove_enemy.emit(enemy.instance)
				enemies_pursuing.remove_at(i)
				
			i += 1
			
		handle_pursuit()
		
		if in_pursuit:
			current_player_location = new_scene_name
			num_enemies_to_spawn = enemies_pursuing.size() -1 
			spawn_timer.start(randf_range(0.7,0.9))
		
""" When the player pauses the game, or when the game is in a cutcene, the timers need to be paused """
func paused_status_changed(value) -> void:
	
	if enemies_pursuing.size() == 0:
		return 
		
	for timer in self.get_children():
		timer.paused = value 

""" Remove enemy from next spawn """
func enemy_timer_timeout(timer: Timer, enemy_array_index: int, timer_array_index: int) -> void:

	enemies_pursuing[enemy_array_index].active = false

	timers.remove_at(timer_array_index)
	
	remove_child(timer)
	timer.queue_free()
	
	handle_pursuit()
	
func handle_pursuit():

	if enemies_pursuing.size() == 0:
		in_pursuit = false
		pursuit_ended.emit()
	
	if not spawn_timer.is_stopped():
			spawn_timer.stop()

	
func _on_spawn_timer_timeout() -> void:

	handle_pursuit()

	if not in_pursuit:
		return
	
	var enemy_spawn_location = enemies_pursuing[num_enemies_to_spawn].current_location
	var previous_instance = enemies_pursuing[num_enemies_to_spawn].instance
	
	if previous_instance != null:
		previous_instance.remove_enemy.emit(previous_instance)
		previous_instance.queue_free()
	
	if enemy_spawn_location != current_player_location:
		var enemy_instance = enemies_pursuing[num_enemies_to_spawn].resource.instantiate()
		
		spawn_enemy.emit(enemy_instance, enemy_spawn_location)
		
		enemies_pursuing[num_enemies_to_spawn].current_location = current_player_location
		enemies_pursuing[num_enemies_to_spawn].instance = enemy_instance
	
	num_enemies_to_spawn -= 1
	
	if num_enemies_to_spawn > 0:
		spawn_timer.start(randf_range(0.3,0.6))
	else: 
		spawn_timer.stop()
