@icon("res://addons/godolibur/Assets/components_icons/saveload.png")
extends Node
class_name Persister

@export var disabled := false

func _ready():
	var current_scene = get_tree().current_scene.get_current_level()
	current_scene.register_persister(self)

func get_valid_parent() -> Node:
	var parent = get_parent()
	
	if parent == null or parent == self:
		printerr("Error!")
		get_tree().quit(2)
	
	if not parent.has_method("load_data"):
		printerr("[Persister]: Parent \"%s\" doesn't contain a \"load_data\" method" % parent.name)
		get_tree().quit(2)
		
	if not parent.has_method("save_data"):
		printerr("[Persister]: Parent \"%s\" doesn't contain a \"save_data\" method" % parent.name)
		get_tree().quit(2)

	return parent

func load_data(data: Dictionary) -> void:

	var parent = get_valid_parent()
	parent.load_data(data)
	
func get_data_to_save() -> Dictionary:
	
	var parent = get_valid_parent()
	
	return parent.save_data()
