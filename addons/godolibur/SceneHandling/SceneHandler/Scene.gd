extends Node2D
class_name Scene

signal scene_ready()

@export var scene_environment : Environment
@export var dark_room = false # A dark room means that when the player enter the screen, the HUD will cover the screen with a black color rect, giving the impression of a dark scene.
@export var entities : Entities
@export var persisters : Array[Persister]

@export_category("Player")
@export var set_player_direction_on_ready := true

# The camera in which the player uses to guide through the scene. 
# Obs.: if this value is not specified in the editor, then the scene will try to find the node through it's children (not including internal)
@export var player_camera : PlayerCamera 

@export_category("Animation")
@export var animation_player : AnimationPlayer

@export_category("Music")
@export var music : AudioStream

var has_loaded_once := false

func find_nodes() -> void:
	for child in get_children():
		
		if child is Entities:
			entities = child

		if child is PlayerCamera:
			player_camera = child
			
		# Both the camera and entities were found
		if player_camera and entities:
			return
			
	if entities == null:
		printerr("[%s]: No \'Entities\' node was found!" % name)
		get_tree().quit(2)
		
	if player_camera == null:
		printerr("[%s]: No \'PlayerCamera\' node was found!" % name)
		get_tree().quit(2)
		
func _ready() -> void:
	if not entities or not player_camera:
		find_nodes()
		
	if dark_room:
		player_camera.setup_bigger_limits()

func start_scene():
	if animation_player:
		animation_player.play("start")

func get_player() -> CharacterBody2D:
	return entities.get_player()

func spawn_player(spawn_information) -> void:
	
	match spawn_information.type:
		
		SceneHandler2D.SpawnType.AT_DOOR:
			
			spawn_player_at_door(spawn_information.door_name,
								int(spawn_information.player_y))
				
		SceneHandler2D.SpawnType.AT_SPECIFIED_POSITION:
			entities.setup_player_in_scene(spawn_information.player.position, spawn_information.player.direction)

func spawn_player_at_door(previous_scene_name: String, player_y: int) -> void:

	var player_direction = null

	if previous_scene_name:
		var spawning_door : Door = get_node_or_null(previous_scene_name)
		
		if spawning_door == null:
			printerr("Error! Spawning door \"%s\" not found, did you misspelled the Scene name?" % previous_scene_name)
			get_tree().quit(1)
			
		var player_position : Vector2 = spawning_door.player_spawn_position
			
		if spawning_door.save_player_y_position:
			spawning_door.calculate_player_y_position(player_y)
			player_position.y = player_y
			

		if set_player_direction_on_ready:
			player_direction = spawning_door.player_direction 
		
		entities.setup_player_in_scene(player_position, player_direction)
		
func spawn_enemy_at_door(enemy: CharacterBody2D, door_name: String) -> void:
	var door : Door = get_node_or_null(door_name)
	
	if door == null:
		printerr("Error! Spawning door \"%s\" not found, did you misspelled the Scene name?" % door_name)
		get_tree().quit(1)
		
	enemy.global_position = door.enemy_spawn.global_position
	entities.add_enemy(enemy)

func register_persister(persister: Persister) -> void:
	persisters.append(persister)

func load_data_from_persisters(scene_data: Dictionary) -> void:

	for persister in persisters:

		var persister_node_path = String(persister.get_path())
		
		if scene_data.has(persister_node_path):
			persister.load_data(scene_data[persister_node_path])
			
	has_loaded_once = false
	
func get_saved_data_from_persisters() -> Dictionary:
	
	var data_to_persist = {}
	
	for persister in persisters:
		
		var persister_node_path = String(persister.get_path())
		
		var persister_data = persister.get_data_to_save()
		
		data_to_persist[persister_node_path] = persister_data
		
	return data_to_persist
	
	
