extends InteractionArea
class_name Door

"""
# Define the possible ways to interact with a door area
#
# Action_pressed: The player needs to be in the area of the door handle
# and press the interaction button
# Collision: The player only needs to be colliding with the door handle
"""
enum InteractionType {Action_pressed, Collision}

signal transition_to_new_scene(destination_scene, door_name, player_y)
signal current_door_state(dialog_data)

# Path to the next scene the player will be transported to
@export_file("*.tscn") var destination_map 

"""
Defines how the player is going to transition to the next scene

Action pressed: the player press the Interaction key and the transition occurs
Collision: The player enter the collision area of the door and the transition happens
"""
@export var type_of_interaction := InteractionType.Action_pressed

"""
Item required for the player to pass the door
"""
@export var save_player_y_position := false

@export_category("Locked status")

@export var door_locked := false
@export var item_needed : GDScript
@export var door_locked_text : = "Door is locked" # Text to be displayed when the door is currently locked
@export var door_locked_cutcene: CompressedTexture2D # Image to be displayed if the door is locked

@export_category("Spawn")
@export var player_spawn : Marker2D
@export var enemy_spawn : Marker2D

@export_category("SFX")
@export var transition_sfx : AudioStream
@export var locked_sfx : AudioStream

var player_spawn_position : Vector2
var player_direction : Vector2

var player_inventory : PlayerInventory

var player_head: StringName

func _ready():
	
	if enemy_spawn == null:
		enemy_spawn = player_spawn
	
	if player_spawn:
		player_spawn_position = player_spawn.global_position
	else:
		player_spawn_position = self.global_position
		
	player_direction = (player_spawn_position - self.global_position).normalized()

	"""
	If monitoring is set to false, then this door is oneway, meaning you cant go
	back
	"""
	if not self.monitoring:
		return
		
	var campaing : Campaing = get_tree().current_scene
	
	if campaing:
		player_head = campaing.get_player_information()["portrait"]
			
		player_inventory = campaing.get_player_inventory()
			
		var scene_handler = campaing.get_scene_handler()
		var hud = campaing.get_hud()

		if not hud or not scene_handler:
			
			if not hud:
				printerr("[%s]: Could not find HUD" % self.name)
				
			if not scene_handler:
				printerr("[%s]: Could not find scene handler" % self.name)
				
			get_tree().quit(1)

		if not destination_map and not is_door_never_meant_to_be_opened():
			printerr("[%s]: No destination was implemented for this door" % self.name)
			
		transition_to_new_scene.connect(scene_handler.new_scene)
		current_door_state.connect(hud.show_dialog_box_text)
	
func interact(_speed_vector : Vector2):
	
	if disabled or type_of_interaction == InteractionType.Collision:
		return
		
	if door_locked:
		
		if not item_needed:
			play_door_locked_cutcene()
			return
		
		var item = item_needed.new()
		
		if player_inventory.has_item(item):
			play_door_unlocked_cutcene()
			door_locked = false
			player_inventory.remove_item(item.name)

		else:
			play_door_locked_cutcene()
				
			

	else:
		request_scene_transition()

func play_door_locked_cutcene() -> void:
	current_door_state.emit(
		{ 
			"text" : [door_locked_text] , 
			"background" :  door_locked_cutcene, 
			"character_name" : "Hiroshi", 
			"character_portrait" : player_head, 
			"vertical_alignment" : 2,
			"sfx" : locked_sfx
		})
		
func play_door_unlocked_cutcene() -> void:
	current_door_state.emit(
		{ 
			"text" : ["The door is now unlocked!"] , 
			"background" :  null, 
			"character_name" : player_inventory.nickname, 
			"character_portrait" : player_head, 
			"vertical_alignment" : 2,
		}
	)

func _on_DoorArea_body_entered(body : PhysicsBody2D ):
	
	if disabled:
		return
	
	if type_of_interaction == InteractionType.Collision:
		
		var player_y = 0
		
		if save_player_y_position:
			pass
			#var player_position = self.collision.global_position.y + collision.shape.get_extents().y/2 - body.global_position.y
			
			#player_y = min(player_position / (collision.shape.get_extents().y),1)
		
		request_scene_transition(player_y)
		
func request_scene_transition(player_y: int = 0) -> void:
	
	if not destination_map and not is_door_never_meant_to_be_opened():
		printerr("Error! No destination scene was implemented to this door")
		return
		
	var spawn_information := {
							"type" : SceneHandler2D.SpawnType.AT_DOOR,
							"door_name" : self.name,
							"player_y" : player_y,
							"sound_effect" : transition_sfx
						}
	transition_to_new_scene.emit(destination_map, spawn_information)

func calculate_player_y_position(player_y: int) -> void:
	self.player_spawn_position.y = (self.collision.global_position.y) * player_y

func is_door_never_meant_to_be_opened():
	return door_locked and not item_needed
	
func load_data(data: Dictionary) -> void:
	door_locked = str_to_var(data.door_locked)
	
func save_data() -> Dictionary:
	var data := {}
	
	data["door_locked"] = var_to_str(door_locked)
	
	return data  
