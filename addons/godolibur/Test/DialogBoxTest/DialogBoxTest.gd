extends Control

# Dialog text example 
var dialog = ["We heard a rumor about a mansion","\nThey say that there is a monster out there!"]

@onready var my_dialog = $DialogBox

# Option choices example
var options = ["Guara?", "Sim", "Não"]

func _ready() -> void:
	
	my_dialog.set_vertical_alignment(2)
	
	my_dialog.set_character_name("Guara do morro")
	my_dialog.show_dialog(dialog)
	
	await my_dialog.dialog_ended
