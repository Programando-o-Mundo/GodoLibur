extends RefCounted
class_name Item

@export var name : String
@export var description : String 
@export var texture : ImageTexture = null : set = _set_texture, get = _get_texture

func _init():
	define_item_properties()
	
func to_json() -> Dictionary:
	return {
		"name" : name,
		"description" : description,
		"texture" : texture.resource_path if texture != null else "",
		"script_path" : "res://Entities/Objects/Pickable/Item.gd"
	}
	
func from_json(dict: Dictionary) -> bool:
	if not dict.has_all(["name", "description", "texture"]):
		printerr("ERROR! default keys not present in the json, skip...")
		return false
		
	name = dict.name
	description = dict.description

	if dict.has("texture") and not dict.texture.is_empty():
		var compressed_texture = Image.new()
		compressed_texture.load(dict.texture)
		
		var image_texture := ImageTexture.create_from_image(compressed_texture)
		
		texture = image_texture
	
	return true


func _set_texture(new_texture : ImageTexture) -> void:
	texture = new_texture

func _get_texture() -> ImageTexture:
	return texture

func define_item_properties() -> void:
	printerr("[%s]: Item properties not defined!" % self.name)

func use(_try_to_use_item: Signal) -> void:
	printerr("[%s]: Usage method not defined or not used" % self.name)
