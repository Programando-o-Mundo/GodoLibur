@icon("res://Assets/components_icons/saveload.png")
extends Node

signal campaing_ready()

var save_scenes_data := []
var campaing_information := {}

var current_campaing : Campaing

func _ready() -> void:
	CampaingsFilesManager.create_save_directory()

func save_game(filename: String = "") -> Dictionary:
	
	if not current_campaing:
		printerr("Error! No active campaing")
		return {}

	if CampaingsFilesManager.save_exist(filename):
		DirAccess.remove_absolute(filename)
		
	else:
		if campaing_information.has("inventory") and campaing_information.inventory.has("player_info"):
			filename = CampaingsFilesManager.generate_filename(campaing_information.inventory.player_info)

	var current_save : FileAccess = CampaingsFilesManager.open_save(filename)
	
	var campaing_information_json = current_campaing.to_json()
	var scenes_information = current_campaing.get_levels_data()
	
	campaing_information_json["save_time"] = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	campaing_information_json["filename"] = filename
	
	current_save.store_line(JSON.stringify(campaing_information_json))
	
	for scene_info in scenes_information:
		current_save.store_line(JSON.stringify(scene_info))

	CampaingsFilesManager.close_save(current_save)

	return campaing_information_json


func load_game(filename: String) -> void:

	if not CampaingsFilesManager.save_exist(filename):
		printerr("ERROR! Save file \"%s\" does not exist!\n" % filename)
		get_tree().quit(2)
	
	var current_save : FileAccess = CampaingsFilesManager.open_save(filename, {"mode_flag" : FileAccess.READ, "open_encrypted" : true})
	
	var saved_data = CampaingsFilesManager.read_saved_data(current_save)
	
	if saved_data.size() == 2:
		campaing_information = saved_data[0]
		save_scenes_data = saved_data[1]
	
	if current_campaing:
		
		current_campaing.reset_campaing()
		current_campaing.load_campaing_state(campaing_information, save_scenes_data)
		
	else:
		start_campaing(campaing_information.campaing_path)
		
	CampaingsFilesManager.close_save(current_save)
	
func start_campaing(campaing_path: String, player_information : Dictionary = {}) -> void:

	var current_scene = get_tree().current_scene
	
	if current_scene:
		get_tree().root.remove_child(current_scene)
		current_scene.queue_free()
	
	var campaing_resource := campaing_path
	current_campaing = load(campaing_resource).instantiate()
	
	current_campaing.start_at_ready = false

	get_tree().root.add_child(current_campaing)
	
	if campaing_information.is_empty():
		current_campaing.start_campaing_at_beginning(player_information.nickname)
		
	else:
		current_campaing.load_campaing_state(campaing_information, save_scenes_data)
		
	campaing_ready.emit()
