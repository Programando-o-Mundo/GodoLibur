extends Resource
class_name Character

@export var name : String
@export var portrait: Texture2D
@export_multiline var description: String

static var default_character = Character.new("Player", null, "default player")

func _init(p_name: String = "Character", 
		   p_portrait: Texture2D = null, 
		   p_description: String = "") -> void:
	name = p_name
	portrait = p_portrait
	description = p_description

func to_json() -> Dictionary:
	return {
		"name" : name,
		"portrait" : portrait,
		"description" : description
 	}
