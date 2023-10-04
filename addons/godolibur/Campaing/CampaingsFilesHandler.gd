class_name CampaingsFilesManager
extends Node

const __ENCRYPTION_KEY : String = "Key"

const SAVE_DIRECTORY := "user://saves"
const SAVE_FILE = "user://saves/%s"
const SAVE_FILE_TEMPLATE := "user://saves/%s.save"

static func create_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		var _err = DirAccess.make_dir_absolute(SAVE_DIRECTORY)

static func save_exist(filename: String) -> bool:
	if not filename.is_valid_filename(): 
		return false 
		
	return FileAccess.file_exists(SAVE_FILE % filename)

static func get_campaing_saved_campaings_information() -> Array:
	
	var available_campaings : Array = []
	
	var files = DirAccess.get_files_at(SAVE_DIRECTORY)
	
	for save in files:
		
		var current_save : FileAccess = open_save(SAVE_FILE % save, 
		{"mode_flag": FileAccess.READ_WRITE, "open_encrypted" : true }
		)
		
		available_campaings.append(read_line(current_save))
		
		close_save(current_save)
	
	return available_campaings
	
static func generate_filename(file_prefix: String) -> String:
		
	var time = Time.get_time_string_from_system()
	
	var filename = "%s-%s" % [file_prefix, time]
	
	return SAVE_FILE_TEMPLATE % filename
	
static func open_save(filename: String, options := {
	"mode_flag" : FileAccess.WRITE, 
	"open_encrypted" : true
}) -> FileAccess:
	
	var current_save : FileAccess
			
	var open_encrypted : bool = options.open_encrypted if options.has("open_encrypted") else false
	var mode_flag = options.mode_flag if options.has("mode_flag") else FileAccess.WRITE
			
	if open_encrypted:
		current_save = FileAccess.open_encrypted(filename, mode_flag, __ENCRYPTION_KEY.to_wchar_buffer())
	
	else:
		current_save = FileAccess.open(filename, mode_flag)
		
	return current_save

static func close_save(file: FileAccess) -> void:
	
	if file.is_open():
		file.flush()
		file.close()
	
static func read_line(file: FileAccess) -> Variant:
	
	if not file.is_open():
		return null
	
	var json = JSON.new()
	
	if file.eof_reached():
		printerr("ERROR! End of file reached!")
		return

	json.parse(file.get_line())
	
	return json.get_data()

static func read_line_at(file: FileAccess, seek_pos: int) -> Variant:
	if seek_pos >= 0:
		file.seek(seek_pos)
		
	return read_line(file)
	
static func read_saved_data(file: FileAccess) -> Array:
	
	if not file.is_open():
		printerr("Error! file is not opened!")
		return []

	var campaing_information : Dictionary = read_line(file)
	
	var save_scenes_data : Array = []
	while file.get_position() < file.get_length():
		var scene_data = read_line(file)
		
		save_scenes_data.append(scene_data)
		
	return [campaing_information, save_scenes_data]
