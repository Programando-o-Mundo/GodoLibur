@icon("res://addons/godolibur/Assets/components_icons/character_icons.png")
extends Node
class_name CharacterRoaster

@export var characters : Dictionary

var player_head : Texture2D
var player_portrait : String

func _ready():
	var player_inventory = get_tree().current_scene.get_player_inventory()
	
	if player_inventory != null:
		
		player_portrait = player_inventory.portrait
		if has_character(player_portrait):
			player_head = characters.get(player_portrait)

func has_character(character_name: StringName) -> bool:
	return characters.has(character_name)

func get_character(character_name: StringName = "") -> Texture2D:
	var name_in_roaster := character_name
	
	if name_in_roaster.is_empty():
		
		if player_head == null:
			return null
			
		name_in_roaster = player_portrait
	
	return characters.get(name_in_roaster)
