@icon("res://Assets/components_icons/saveload.png")
extends Node

const __ENCRYPTION_KEY : String = "Key"

const SAVE_DIRECTORY := "user://saves"
const SAVE_FILE = "user://saves/%s"
const SAVE_FILE_TEMPLATE := "user://saves/%s.save"

var save_scenes_data := []
var campaing_information := {}

func _ready():
	
	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		var _err = DirAccess.make_dir_absolute(SAVE_DIRECTORY)


func get_save_files_campaing_information() -> Array:
	
	var available_campaings : Array = []
	
	var files = DirAccess.get_files_at(SAVE_DIRECTORY)
	
	for save in files:
		
		var current_save : FileAccess = open_save(SAVE_FILE % save, FileAccess.READ_WRITE)
		
		available_campaings.append(read_line(current_save))
		
		close_save(current_save)
	
	return available_campaings

func generate_filename(current_campaing: CampaingHandler) -> String:
	var player_name = current_campaing.get_player_information().nickname
	var time = Time.get_time_string_from_system()
	
	var filename = "%s-%s" % [player_name, time]
	
	return SAVE_FILE_TEMPLATE % filename

func read_line(file: FileAccess):
	var json = JSON.new()
	
	if file.eof_reached():
		printerr("ERROR! End of file reached!")
		get_tree().quit(2)

	json.parse(file.get_line())
	
	return json.get_data()

func read_line_at(file: FileAccess, seek_pos: int):
	if seek_pos >= 0:
		file.seek(seek_pos)
		
	return read_line(file)
	
func read_campaing_information(file: FileAccess):
	
	if not file.is_open():
		printerr("Error! file is not opened!")
		return campaing_information

	campaing_information = read_line(file)
	
	save_scenes_data.clear()
	while file.get_position() < file.get_length():
		var scene_data = read_line(file)
		
		save_scenes_data.append(scene_data)

	

func open_save(filename: String, mode_flag := FileAccess.WRITE, open_encrypted: bool = false) -> FileAccess:
	
	var current_save : FileAccess
			
	if open_encrypted:
		current_save = FileAccess.open_encrypted(filename, mode_flag, __ENCRYPTION_KEY.to_wchar_buffer())
	
	else:
		current_save = FileAccess.open(filename, mode_flag)
		
	return current_save

func close_save(file: FileAccess) -> void:
	
	file.flush()
	file.close()

func save_game(filename: String = "") -> Dictionary:

	var current_campaing = get_tree().current_scene
	
	if not current_campaing is CampaingHandler:
		printerr("Error! No active campaing")
		return {}

	if filename.is_empty():
		filename = generate_filename(current_campaing)

	if FileAccess.file_exists(filename):
		DirAccess.remove_absolute(filename)
	
	var current_save : FileAccess = open_save(filename)
	
	var campaing_information_json = current_campaing.to_json()
	var scenes_information = current_campaing.get_levels_data()
	
	campaing_information_json["save_time"] = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	campaing_information_json["filename"] = filename
	
	current_save.store_line(JSON.stringify(campaing_information_json))
	
	for scene_info in scenes_information:
		current_save.store_line(JSON.stringify(scene_info))

	close_save(current_save)

	return campaing_information_json


func load_game(filename: String) -> void:

	if not FileAccess.file_exists(filename):
		printerr("ERROR! Save file %s does not exist!\n" % filename)
		get_tree().quit(2)
	
	var current_save : FileAccess = open_save(filename, FileAccess.READ)
	
	read_campaing_information(current_save)
	
	var current_scene = get_tree().current_scene
	
	if current_scene is CampaingHandler:
		
		current_scene.reset_campaing()
		current_scene.load_campaing_state(campaing_information, save_scenes_data)
		
	else:
		start_campaing(campaing_information.campaing_path)

		
	close_save(current_save)
	
func start_campaing(campaing_path: String, player_information : Dictionary = {}) -> void:
	
	var current_scene = get_tree().current_scene
	
	var campaing_resource := campaing_path
	
	var campaing_instance : CampaingHandler = load(campaing_resource).instantiate()
	campaing_instance.tree_entered.connect(get_tree().set_current_scene.bind(campaing_instance), CONNECT_ONE_SHOT)
	campaing_instance.start_at_ready = false
	
	get_tree().root.remove_child(current_scene)
	
	get_tree().root.add_child(campaing_instance)
	
	get_tree().current_scene = campaing_instance
	
	if campaing_information.is_empty():
		campaing_instance.start_campaing_at_beginning(player_information.nickname)
		
	else:
		campaing_instance.load_campaing_state(campaing_information, save_scenes_data)
