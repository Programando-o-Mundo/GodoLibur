extends CanvasLayer
class_name HUD

signal cutcene_started()
signal cutcene_ended()

signal dialog_open()
signal dialog_closed(option)

signal correct_password_inputted()
signal correct_item_used(cutcene_name, item)

@export var password_cutcene : PackedScene 
@export var audio_manager : GameAudioManager 
@export var player_information : PlayerInventory

@export var dialog_box : DialogBox 
@export var gui : GameGUI 
@export var static_cutcene : StaticCutcene 
@export var room_visibility : RoomVisibility 
@export var password_inputter : PasswordInputter 
@export var background_color : ColorRect 

var current_campaing : CampaingHandler
var password_cutcene_node : PasswordInputter = null

var custom_cutcenes_instances = {}

func _ready():
	current_campaing = get_tree().current_scene
	dialog_box.visible = false
	password_inputter.visible = false
	room_visibility.visible = false
	background_color.visible = false
	static_cutcene.visible = false
	
func get_cutcene_instance(cutcene: PackedScene, cutcene_name: String) -> CutceneInterface:
	
	var cutcene_instance : CutceneInterface = null
	
	if custom_cutcenes_instances.has(cutcene_name):
		cutcene_instance = custom_cutcenes_instances[cutcene_name]
		
	else:
		
		cutcene_instance = cutcene.instantiate()
		add_child(cutcene_instance)
		custom_cutcenes_instances[cutcene_name] = cutcene_instance
		
	return cutcene_instance

func show_password_puzzle(password: String, background_texture : CompressedTexture2D):
	
	if current_campaing.in_cutcene:
		return
	
	password_inputter.password = password
	password_inputter.background_texture = background_texture
	
	cutcene_started.emit()
	
	password_inputter.show_screen()
	
	var password_is_correct = await password_inputter.password_inputted
	
	if password_is_correct:
		correct_password_inputted.emit()
		
	cutcene_ended.emit()
	
func show_custom_cutcene(cutcene: PackedScene, cutcene_name: String) -> void:

	if current_campaing.in_cutcene:
		return
		
	var cutcene_instance = get_cutcene_instance(cutcene, cutcene_name)
		
	cutcene_started.emit()
	cutcene_instance.play_cutcene()
	
	await cutcene_instance.cutcene_ended
	
	cutcene_ended.emit()

func use_item_on_cutcene(cutcene: PackedScene, cutcene_name: String, item: Item):
	
	if current_campaing.in_cutcene:
		return
	
	var cutcene_instance = get_cutcene_instance(cutcene, cutcene_name)
	
	var success = cutcene_instance.use_item(item)

	if success:
		correct_item_used.emit(cutcene_name,item)
		cutcene_started.emit()
		
		cutcene_instance.play_cutcene()
		await cutcene_instance.cutcene_ended
		cutcene_ended.emit()
		

func show_static_cutcene(background_texture : CompressedTexture2D, script : GDScript ) -> void:
	
	if current_campaing.in_cutcene:
		return
	
	cutcene_started.emit()
	static_cutcene.play_cutcene(background_texture, script)
	
	await static_cutcene.cutcene_ended
	
	cutcene_ended.emit()
	
func show_background_color(background_is_visible: bool = true, color: Color = Color.BLACK) -> void:
	
	background_color.color = color
	background_color.visible = background_is_visible
	
func show_dialog_box_text(properties : Dictionary = 
	{ 
		"text" : [] , 
		"background" :  null, 
		"character_name" : "Hiroshi", 
		"character_portrait" : current_campaing.get_player_information()["portrait"], 
		"vertical_alignment" : 2,
	} ) -> void:

	if current_campaing.in_dialog:
		return

	self.dialog_open.emit()

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
		printerr("[HUD]: Incorrect usage of dialog mechanic, dictionary need \"text\" property")
		
	self.dialog_closed.emit(option)
	self.dialog_box.visible = false

func on_item_picked(item: Item):

	self.dialog_open.emit()
	
	dialog_box.set_character_name(player_information.nickname)
	dialog_box.set_character_portrait(current_campaing.get_character_head())
	dialog_box.set_vertical_alignment(2)
	
	dialog_box.show_dialog(["I found the item, \"%s\"" % item.name])
	var option = await dialog_box.dialog_ended
		
	self.dialog_closed.emit(option)
	self.dialog_box.visible = false

func _on_scene_handler_scene_changed(_current_scene_name: String) -> void:
	background_color.visible = false
