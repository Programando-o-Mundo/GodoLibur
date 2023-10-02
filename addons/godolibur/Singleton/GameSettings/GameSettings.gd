extends Node

# All possibles AudioBuses
enum AudioBuses {
	Master = 0,
	Music = 1,
	SFX = 2
}

# All possibles Display modes
enum DisplayModes {
	Fullscreen,
	Windowed,
	Borderless
}

# When saving the settings, you can not only... well, save, but you can
# also reset, or cancel
enum SettingsMode {
	Reset,
	Save,
	Cancel
}

# Constant values

# Name of the sections in the .cfg file
const DISPLAY_SECTION = "display_settings"
const AUDIO_SECTION   = "audio_settings"

# Name of the .cfg file
const USER_SETTINGS_FILE = "user://settings.cfg" 

# Default settings value
const DEFAULT_DISPLAY_MODE = DisplayModes.Windowed 

const DEFAULT_MASTER_AUDIO_LEVEL : = 0
const DEFAULT_MUSIC_AUDIO_LEVEL  : = 0
const DEFAULT_SFX_AUDIO_LEVEL    : = 0

const DEFAULT_VSYNC_VALUE : = false

var current_display_mode : get = get_display_mode, set = change_display_mode

# Open the settings folder, and configure game settings
func _ready() -> void:
	
	var config = ConfigFile.new()
	var err = config.load(USER_SETTINGS_FILE)
	
	# The settings file does not exist, this is the first time the player enters the game
	# and so the config files must be created and set with the default values
	if err != OK:
		
		config.set_value(DISPLAY_SECTION,"display_mode",DEFAULT_DISPLAY_MODE)
		config.set_value(DISPLAY_SECTION,"vsync_enabled", DEFAULT_VSYNC_VALUE)
		
		config.set_value(AUDIO_SECTION,str(AudioBuses.Master),DEFAULT_MASTER_AUDIO_LEVEL)
		config.set_value(AUDIO_SECTION,str(AudioBuses.Music),DEFAULT_MUSIC_AUDIO_LEVEL)
		config.set_value(AUDIO_SECTION,str(AudioBuses.SFX),DEFAULT_SFX_AUDIO_LEVEL)
		
		self.current_display_mode = DEFAULT_DISPLAY_MODE
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (DEFAULT_VSYNC_VALUE) else DisplayServer.VSYNC_DISABLED)
		
		AudioServer.set_bus_volume_db(AudioBuses.Master, DEFAULT_MASTER_AUDIO_LEVEL)
		AudioServer.set_bus_volume_db(AudioBuses.Music, DEFAULT_MUSIC_AUDIO_LEVEL)
		AudioServer.set_bus_volume_db(AudioBuses.SFX, DEFAULT_SFX_AUDIO_LEVEL)
	
	else:
		# Read all sections in the configurations file, and
		# set the files
		for settings in config.get_sections():

			if settings == DISPLAY_SECTION:
				
				var display_mode = config.get_value(settings, "display_mode",DEFAULT_DISPLAY_MODE)
				var vsync_enabled = config.get_value(settings, "vsync_enabled",DEFAULT_VSYNC_VALUE)
				
				change_vsync(vsync_enabled)
				self.current_display_mode = display_mode

			if settings == AUDIO_SECTION:
				
				var master_audio_level = config.get_value(settings, str(AudioBuses.Master),DEFAULT_MASTER_AUDIO_LEVEL)
				var music_audio_level  = config.get_value(settings, str(AudioBuses.Music),DEFAULT_MUSIC_AUDIO_LEVEL)
				var sfx_audio_level    = config.get_value(settings, str(AudioBuses.SFX),DEFAULT_SFX_AUDIO_LEVEL)
				
				change_audio_bus_volume(AudioBuses.Master,master_audio_level)
				change_audio_bus_volume(AudioBuses.Music,music_audio_level)
				change_audio_bus_volume(AudioBuses.SFX,sfx_audio_level)
			
	config.save(USER_SETTINGS_FILE)

# Setter for the display mode. For each display mode, specific variables
# must be set to either true or false
func change_display_mode(display_mode : int) -> void:
	
	if display_mode == null:
		return
	
	current_display_mode = display_mode
	
	match display_mode:
			
		DisplayModes.Fullscreen:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
			
		DisplayModes.Windowed:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
			get_window().borderless = false
			
		DisplayModes.Borderless:
			get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
			get_window().borderless = true
	
func get_display_mode() -> int:
	return current_display_mode
	
func change_audio_bus_volume(audio_bus : int ,audio_level : float):
	AudioServer.set_bus_volume_db(audio_bus, audio_level)
	AudioServer.bus_layout_changed.emit()
	
func change_vsync(value : bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (value) else DisplayServer.VSYNC_DISABLED)
	
# This functions is responsible to open the configurations file again, to either
# save, reset or cancel the current settings, this is to
func configure_settings(settings_type : = SettingsMode.Save) -> void:
	
	var config = ConfigFile.new()
	var _err = config.load(USER_SETTINGS_FILE)
	
	var master_audio_level 
	var music_audio_level  
	var sfx_audio_level    
	
	var display_mode
	var vsync
	
	match settings_type:
		
		SettingsMode.Reset:
			
			AudioServer.set_bus_volume_db(AudioBuses.Master, DEFAULT_MASTER_AUDIO_LEVEL)
			AudioServer.set_bus_volume_db(AudioBuses.Music, DEFAULT_MUSIC_AUDIO_LEVEL)
			AudioServer.set_bus_volume_db(AudioBuses.SFX, DEFAULT_SFX_AUDIO_LEVEL)
			
			master_audio_level = DEFAULT_MASTER_AUDIO_LEVEL
			music_audio_level  = DEFAULT_MUSIC_AUDIO_LEVEL
			sfx_audio_level    = DEFAULT_SFX_AUDIO_LEVEL
			
			display_mode = DEFAULT_DISPLAY_MODE
			vsync        = DEFAULT_VSYNC_VALUE
			
			self.current_display_mode = display_mode
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (vsync) else DisplayServer.VSYNC_DISABLED)
			
		SettingsMode.Save:
			
			master_audio_level = AudioServer.get_bus_volume_db(AudioBuses.Master)
			music_audio_level  = AudioServer.get_bus_volume_db(AudioBuses.Music)
			sfx_audio_level    = AudioServer.get_bus_volume_db(AudioBuses.SFX)
			
			display_mode = current_display_mode
			vsync        = (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED)
	
	config.set_value(AUDIO_SECTION,str(AudioBuses.Master),master_audio_level)
	config.set_value(AUDIO_SECTION,str(AudioBuses.Music),music_audio_level)
	config.set_value(AUDIO_SECTION,str(AudioBuses.SFX),sfx_audio_level)
	
	config.set_value(DISPLAY_SECTION,"display_mode",display_mode)
	config.set_value(DISPLAY_SECTION,"vsync_enabled",vsync)
	
	config.save(USER_SETTINGS_FILE)
