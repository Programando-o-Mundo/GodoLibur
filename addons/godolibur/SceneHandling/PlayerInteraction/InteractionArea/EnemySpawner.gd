extends Area2D

signal spawn_enemy()

@export_file("*.tscn") var enemy

@onready var marker = $SpawnPosition

func _ready() -> void:
	
	var scene_handler = get_tree().current_scene.get_scene_handler()
	if scene_handler == null:
		get_tree().quit(2)
		
	spawn_enemy.connect(scene_handler.start_enemy_pursuit_on_current_scene)

func _on_body_entered(_body: Node2D) -> void:
	spawn_enemy.emit(enemy, marker.global_position)
