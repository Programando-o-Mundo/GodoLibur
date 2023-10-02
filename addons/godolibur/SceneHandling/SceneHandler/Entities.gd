extends Node2D
class_name Entities

var player : CharacterBody2D

var current_enemy

func _ready() -> void:
	_find_player()

func _find_player() -> void:
	for child in get_children():
		
		if child is Node:
			player = child
			return
			
	if player == null:
		printerr("[%s]: No \'Player\' node was found!" % name)

func add_enemy(enemy: CharacterBody2D) -> void:
	call_deferred("add_child", enemy)
		
	current_enemy = enemy
	enemy.call_deferred("enemy_setup")
	enemy.remove_enemy.connect(self.remove_enemy)
		
func remove_enemy(enemy: CharacterBody2D) -> void:
	call_deferred("remove_child", enemy)

func setup_player_in_scene(player_position: Vector2, direction) -> void:
	player.visible = true
	
	if direction != null:
		player.set_direction(direction)
	
	player.global_position = player_position
