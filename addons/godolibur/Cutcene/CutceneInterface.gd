extends Control
class_name CutceneInterface

@export var default_cutcene_script : GDScript 

signal cutcene_ended()

var is_active : bool = false
var current_script = null

func play_cutcene(_cutcene_texture: CompressedTexture2D = null, _script: GDScript = null) -> void:
	is_active = true
	
func hide_cutcene() -> void:
	is_active = false
	if current_script:
		current_script.is_active = false
	
func use_item(_item: Item) -> bool:
	printerr("function not implemented")
	return false
	
func play_script(script: GDScript = null):
	
	if current_script == null:
	
		if script == null: 
			
			current_script = default_cutcene_script.new()
			add_child(current_script, false, Node.INTERNAL_MODE_FRONT)
		else:
			
			current_script = script.new()
			add_child(current_script, false, Node.INTERNAL_MODE_FRONT)
			
	current_script.play(hide_cutcene)


