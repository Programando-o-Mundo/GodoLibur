extends Control
class_name DialogBoxHandler

@export var dialog_box : DialogBox 
@export var audio_manager : GameAudioManager

var current_campaing : Campaing

func _ready():
	current_campaing = CampaingOverseer.current_campaing

func show_text(properties : Dictionary = 
	{ 
		"text" : [] , 
		"background" :  null, 
		"character_name" : "Player", 
		"character_portrait" : current_campaing.get_player_information()["portrait"], 
		"vertical_alignment" : 2,
	} ) -> void:

	if current_campaing.in_dialog:
		return

	if properties.has("character_name"): dialog_box.set_character_name(properties.character_name)
		
	if properties.has("character_portrait"): 
		
		var texture = current_campaing.get_character_head(properties.character_portrait)
		dialog_box.set_character_portrait(texture)
		
	if properties.has("vertical_alignment"): dialog_box.set_vertical_alignment(properties.vertical_alignment)

	if properties.has("sfx"): audio_manager.play_sfx(properties.sfx)
		
	var option
		
	if  properties.has("text"):
		
		dialog_box.show_dialog(properties.text)
		option = await dialog_box.dialog_ended
	else:
		printerr("[%s]: Incorrect usage of dialog mechanic, dictionary need \"text\" property" % name)

	dialog_box.visible = false
