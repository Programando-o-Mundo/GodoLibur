extends Control

# Store the dialog system scene
@export var dialog_scene: PackedScene 

# Dialog text example 
var dialog = ["We heard a rumor about a mansion","\nThey say that there is a monster out there!"]
			
# Option choices example
var options = ["Guara?", "Sim", "Não"]

func _ready() -> void:

	var my_dialog : DialogBox = dialog_scene.instantiate()
	add_child(my_dialog)
	
	my_dialog.dialog_ended.connect(after_dialog)
	my_dialog.set_vertical_alignment(2)
	
	my_dialog.set_character_name("Guara do morro")
	my_dialog.show_dialog(dialog)
	
func after_dialog(option : String) -> void:
	print(option)
