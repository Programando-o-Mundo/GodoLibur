@tool
@icon("res://addons/godolibur/Assets/components_icons/scene.png")
extends Node2D
class_name SceneHandler2D

signal scene_transition_requested()
signal scene_transition_completed()

signal scene_changed(current_scene_name)
signal current_scene_is_dark_room()
signal current_scene_is_lit()

@export_storage var world_environment : WorldEnvironment
@export_storage var enemy_controller : EnemyController
@export_storage var audio_manager : GameAudioManager

var current_scene : Scene
var previous_scene : Scene
var scene_environment : Environment : set = set_scene_environment

var scenes := {}

enum SpawnType {
	NOT_SPECIFIED,
	AT_DOOR,
	AT_SPECIFIED_POSITION
}

func _ready() -> void:
	
	if Engine.is_editor_hint():
		_tool_ready()
		return
		
	if enemy_controller != null:
		enemy_controller.pursuit_started.connect(pursuit_started)
		enemy_controller.pursuit_ended.connect(pursuit_ended)

func _tool_ready() -> void:
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)
	update_configuration_warnings()
	
func _get_configuration_warnings() -> PackedStringArray:
	var errors := []
	
	if world_environment == null:
		errors.append("Make sure to add a WorldEnvironment node")
	
	if enemy_controller == null:
		errors.append("Make sure to add a EnemyController node")
		
	if audio_manager == null:
		errors.append("Your SceneHandler does not have a AudioManager")
		
	return errors

func clear():
	remove_child(current_scene)
	
	current_scene = null
	previous_scene = null
	scenes.clear()

func get_scenes_current_state() -> Array:
	
	var scene_state := []
	
	scenes[current_scene.scene_file_path].persisters = current_scene.get_saved_data_from_persisters()
	
	var filepaths = scenes.keys()
	
	for i in range(filepaths.size()):
		var scene_filepath = filepaths[i]
		
		scene_state.append({"filepath" : scene_filepath, 
							"save_data" : scenes[scene_filepath].persisters})  
	
	return scene_state

func load_scenes_persisters(scenes_persisters: Array) -> void:

	if scenes_persisters == null or scenes_persisters.is_empty():
		return

	for persister in scenes_persisters:
		scenes[persister.filepath] = {"instance" : null, "persisters" : persister.save_data}	

func set_scene_environment(new_environment : Environment) -> void :
	
	if new_environment != null:
		scene_environment = new_environment
		world_environment.environment = scene_environment

"""
Function to change the scene, when the player moves to
new scene
"""
func new_scene(new_scene_path : String, spawn_information := {
									"type" : SpawnType.NOT_SPECIFIED,
									"door_name" : "",
									"player_y" : 0,
								}) -> void:
	
	scene_transition_requested.emit()
	
	previous_scene = current_scene
	
	if current_scene != null:
		scenes[current_scene.scene_file_path].persisters = current_scene.get_saved_data_from_persisters()
 
	var next_scene : Scene = load_next_scene(new_scene_path)
	
	add_child.call_deferred(next_scene)
	
	next_scene.scene_file_path = new_scene_path
	
	if spawn_information.has("door_name"):
		spawn_information.door_name = _find_next_scene_name(spawn_information.door_name)
		
	if spawn_information.has("sound_effect"):
		audio_manager.play_sfx(spawn_information.sound_effect) 
		
	next_scene.spawn_player.call_deferred(spawn_information)
	
	#var enemies = enemy_controller.get_enemies()
	
	if current_scene != null:
		remove_child.call_deferred(current_scene)

	set_scene_environment(next_scene.scene_environment)
	
	if next_scene.dark_room:
		current_scene_is_dark_room.emit()
		
	if next_scene.music:
		
		if not enemy_controller.in_pursuit:
			audio_manager.play_music(next_scene.music)
	
	current_scene = next_scene

	if not current_scene.has_loaded_once and current_scene_has_persistent_data(new_scene_path):
		current_scene.load_data_from_persisters.call_deferred(scenes[new_scene_path].persisters)
	
	current_scene.start_scene()
	
	current_scene.scene_ready.emit.call_deferred()
	scene_changed.emit(current_scene.name)
	
	scene_transition_completed.emit()
	
func load_next_scene(destination_path):

	if scenes.has(destination_path) and scenes[destination_path].instance != null:
		return scenes[destination_path].instance

	if not ResourceLoader.exists(destination_path):
		printerr("Error! The destination %s provided is not a Scene or does not exist" % destination_path)
		get_tree().quit(1)
	
	var next_scene_resource = load(destination_path)
	var next_scene : Scene = next_scene_resource.instantiate()	
	
	if not scenes.has(destination_path):
		scenes[destination_path] = {"instance" : next_scene, "persister" : {}}
	else:
		scenes[destination_path].instance = next_scene
	
	return next_scene

func light_source_created() -> void:
	current_scene.camera.setup_shorter_limits()
	current_scene_is_lit.emit()

func start_enemy_pursuit_on_current_scene(enemy_resource: String, spawn_position: Vector2, options: Dictionary = {}) -> void:
	
	if options.has("pursuit_time"):
		enemy_controller.enemy_pursuit_time_sec = options.pursuit_time
	
	var enemy : CharacterBody2D = enemy_controller.start_pursuit(enemy_resource, current_scene.name)

	enemy.global_position = spawn_position
	
	current_scene.entities.add_enemy(enemy)

func spawn_enemy_on_door_in_current_scene(enemy: CharacterBody2D, previous_location: String) -> void:
	current_scene.spawn_enemy_at_door(enemy, previous_location)

func current_scene_has_persistent_data(new_scene_path: String) -> bool:
	return scenes[new_scene_path].has("persisters") and not scenes[new_scene_path].persisters.is_empty()

"""
Returns the name of the next scene, while also taking
into account if there was a duplicate door
"""
func _find_next_scene_name(door_name : String) -> String:
	
	if current_scene == null:
		return door_name
	
	var duplicate_door = door_name.split("-")
	
	var scene_name : String = current_scene.name
	
	if duplicate_door.size() > 1:
		scene_name += "-" + str(duplicate_door[1])
		
	return scene_name

func pursuit_started():
	audio_manager.play_music(enemy_controller.pursuit_theme)
	
func pursuit_ended():
	audio_manager.crossfade_music(current_scene.music)

func _on_child_entered_tree(node):
	if not Engine.is_editor_hint():
		return
		
	if node is WorldEnvironment:
		world_environment = node
		update_configuration_warnings()
		
	elif node is EnemyController:
		enemy_controller = node
		update_configuration_warnings()
		
	elif node is GameAudioManager:
		audio_manager = node
		update_configuration_warnings()

func _on_child_exiting_tree(node):
	if not Engine.is_editor_hint():
		return
		
	if node is WorldEnvironment:
		world_environment = null
		update_configuration_warnings()
		
	elif node is EnemyController:
		enemy_controller = null
		update_configuration_warnings()
		
	elif node is GameAudioManager:
		audio_manager = null
		update_configuration_warnings()
		
