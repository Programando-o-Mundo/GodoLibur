@tool
@icon("res://addons/godolibur/Assets/components_icons/map.png")
class_name Campaing
extends Node

signal paused_status_changed(status)

@onready var game_gui : GameGUI
@onready var scene_handler : SceneHandler2D
@onready var stopwatch : Stopwatch 
@onready var player_inventory : PlayerInventory
@export var character_roaster : CharacterRoaster

@export_category("Scene handling")
@export var starting_scene : PackedScene : set = _set_starting_scene, get = _get_starting_scene

@export_category("Debug")
@export var start_at_ready := false

var player_head : Texture2D = null

var in_cutcene := false
var in_dialog := false 
var in_menu := false

func _ready() -> void:
	
	if Engine.is_editor_hint():
		_tool_ready()
		return
		
	for child in get_children():
		if child is GameGUI:
			game_gui = child
		elif child is SceneHandler2D:
			scene_handler = child
		elif child is Stopwatch:
			stopwatch = child
		elif child is PlayerInventory:
			player_inventory = child

	if scene_handler != null:
		scene_handler.scene_transition_requested.connect(change_cutcene_status.bind(true))
		scene_handler.scene_transition_completed.connect(change_cutcene_status.bind(false))

	if start_at_ready:
		start_campaing_at_beginning(Character.default_character)
		
func _tool_ready() -> void:
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree, CONNECT_PERSIST)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree, CONNECT_PERSIST)
	update_configuration_warnings()
	
func _set_starting_scene(scene: PackedScene) -> void:
	if scene:
		starting_scene = scene
	
func _get_starting_scene() -> PackedScene:
	return starting_scene
	
func _get_configuration_warnings() -> PackedStringArray:
	var errors := []
	
	if scene_handler == null:
		errors.append("Make sure the Campaing has a SceneHandler2D node, this node is necessary!")
	
	if game_gui == null:
		errors.append("Make sure the Campaing has a GameGUI node, this node is necessary!")
		
	if player_inventory == null:
		errors.append("Your campaing does not have a Player Inventory")
		
	if stopwatch == null:
		errors.append("Your campaing does not have a Stopwatch, total game runtime will not be calculated")
		
	if not starting_scene:
		errors.append("Your campaing does not have a Starting Scene! Make sure to add one!")
		
	return errors
		
func _on_child_entered_tree(node):
	if not Engine.is_editor_hint():
		return

	if node is SceneHandler2D:
		scene_handler = node
		update_configuration_warnings()
	elif node is GameGUI:
		game_gui = node
		update_configuration_warnings()
	elif node is PlayerInventory:
		player_inventory = node
		update_configuration_warnings()
	elif node is Stopwatch:
		stopwatch = node
		update_configuration_warnings()

func _on_child_exiting_tree(node):
	
	if not Engine.is_editor_hint():
		return
	
	if node is SceneHandler2D:
		scene_handler = null
		update_configuration_warnings()
	elif node is GameGUI:
		game_gui = null
		update_configuration_warnings()
	elif node is PlayerInventory:
		player_inventory = null
		update_configuration_warnings()
	elif node is Stopwatch:
		stopwatch = null
		update_configuration_warnings()

func reset_campaing() -> void:
	player_inventory.clear()
	scene_handler.clear()

func start_campaing_at_beginning(player_information: Character) -> void:
	if not player_information:
		player_inventory.character_information = player_information

	if not starting_scene:
		printerr("Error! No starting scene was specified! Invalid Campaing!")
		get_tree().quit(2)

	scene_handler.new_scene(starting_scene.resource_path)

func get_player_inventory() -> PlayerInventory:
	return player_inventory
	
func gui_available_to_show() -> bool:
	return not in_cutcene and not in_dialog and not in_menu and not is_player_in_pursuit()
	
func is_player_in_pursuit() -> bool:
	return scene_handler.enemy_controller.in_pursuit if scene_handler.enemy_controller else false
	
func get_player_information() -> Dictionary:
	return player_inventory.get_player_information()
	
func has_character_head(character_name: StringName) -> bool:
	return character_roaster.has_character(character_name)
	
func get_character_head(character_name: StringName = "") -> Texture2D:
	return character_roaster.get_character(character_name).portrait
	
func get_game_gui() -> GameGUI:
	return game_gui
	
func get_scene_handler() -> SceneHandler2D:
	return scene_handler
	
func get_current_time() -> String:
	return stopwatch.get_current_time_as_string() if stopwatch else ""

func get_current_scene() -> Scene:
	return scene_handler.current_scene
	
func get_levels_data() -> Array:
	return scene_handler.get_scenes_current_state()
	
func get_campaing_audio_manager() -> GameAudioManager:
	return scene_handler.audio_manager

func game_over() -> void:
	get_tree().change_scene_to_file("res://Menus/GameOver/GameOverScreen.tscn")
	
func campaing_over() -> void:
	var campaing_over_scene = load("res://Campaings/SouthPark/CampaingOver/CampaingOver.tscn").instantiate()
	campaing_over_scene.tree_entered.connect(get_tree().set_current_scene.bind(campaing_over_scene), CONNECT_ONE_SHOT)
	
	get_tree().root.add_child(campaing_over_scene)
	campaing_over_scene.show_screen(stopwatch.get_current_time_as_string())
	
	queue_free()

func change_in_menu_status(menu_status: bool) -> void:
	in_menu = menu_status 
	_pause_tree()

func change_cutcene_status(cutcene_is_on: bool) -> void:
	in_cutcene = cutcene_is_on
	_pause_tree()
	
func change_dialog_status(_option: String, dialog_is_on: bool) -> void:
	in_dialog = dialog_is_on
	_pause_tree()
		
func _pause_tree():
	get_tree().paused = in_cutcene or in_dialog or in_menu
	paused_status_changed.emit(in_menu)
	
func to_json() -> Dictionary:
	
	var campaing_json := {"campaing_path" : self.scene_file_path}
	
	var current_scene = get_current_scene()
	
	if current_scene:
		campaing_json["current_scene_path"] = current_scene.scene_file_path
	
	var player = current_scene.get_player()
	
	if player != null and player.has_method("to_json"):
		campaing_json["player"] = player.to_json()
	
	if stopwatch:
		campaing_json["total_game_time"] = stopwatch.time 
	
	if player_inventory:
		campaing_json["inventory"] = player_inventory.get_json()
	
	return campaing_json

func load_campaing_state(campaing_information: Dictionary, saved_scenes_data: Array) -> void:
	
	var spawn_data := {"type" : SceneHandler2D.SpawnType.AT_SPECIFIED_POSITION} 
	
	if campaing_information.has("inventory") and player_inventory:
		player_inventory.nickname = campaing_information.player.nickname
		player_inventory.set_items_from_json(campaing_information.inventory)

	if campaing_information.has("total_game_time") and stopwatch:
		stopwatch.time = campaing_information.total_game_time
		
	if campaing_information.has("player"):
		spawn_data["player"] = str_to_var(campaing_information.player)
	
	scene_handler.load_scenes_persisters(saved_scenes_data)
	
	scene_handler.new_scene(campaing_information.current_scene_path, spawn_data)
