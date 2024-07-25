@icon("res://addons/godolibur/Assets/components_icons/character_icons.png")
class_name CharacterRoaster
extends Resource

@export var characters : Array[Character]

var player_information : Character 

func _ready():
	var player_inventory = CampaingOverseer.current_campaing.get_player_inventory()
	
	if player_inventory != null:
		
		player_information = player_inventory.character_information

func has_character(character_name: String) -> bool:
	var character: Character = null
	for chr in characters:
		if chr.name == character_name:
			character = chr
			break
			
	return character != null

func get_character(character_name: StringName = "") -> Character:
	var character: Character = null
	for chr in characters:
		if chr.name == character_name:
			character = chr
			break
			
	return character
	
func get_player_character() -> Character:
	return player_information
