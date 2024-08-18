@tool
extends Control
class_name MenuController

signal menu_opened()
signal menu_closed()
signal menu_screen_changed(screen_name)

@export var open_gui_command : StringName = "ui_home"

@export_category("Screens")
@export var screens : Array[SimpleScreen]
@export var main_screen : SimpleScreen :
	set(new_main_screen):
		main_screen = new_main_screen
		if Engine.is_editor_hint():
			update_configuration_warnings()
			
			
@export_category("Animations")
@export var menu_animation : AnimationPlayer
@export var open_menu_animation : String = "open"
@export var close_menu_animation : String = "close"

var current_ui : SimpleScreen

func _get_configuration_warnings() -> PackedStringArray:
	
	var errors := []
	
	if main_screen == null:
		errors.append("Make sure a main screen specified, its necessary!")
		
	return errors

func _ready() -> void:
	
	if Engine.is_editor_hint():
		_tool_ready()
		return
	
	for screen in screens:
		screen.visible = false 
		
		screen.exit_screen.connect(exit_current_screen)
		screen.force_quit.connect(force_quit_menu)

	main_screen.exit_screen.connect(exit_current_screen)
	main_screen.force_quit.connect(force_quit_menu)
	main_screen.open_screen.connect(open_screen)

func _tool_ready() -> void:
	update_configuration_warnings()

func _input(event : InputEvent ) -> void:

	if event.is_action_pressed(open_gui_command):
		
		if current_ui != null:
			current_ui.hide_screen()
			
		else:
			menu_closed.emit()
				
func play_menu_animation(animation_name: StringName) -> void:
	
	if menu_animation != null:
		return
		
	if not menu_animation.has_animation(animation_name):
		return
		
	menu_animation.play(animation_name)
	
func open_screen(new_current_ui_node_name: String) -> void:
	
	var new_current_ui = get_node(new_current_ui_node_name)
	
	if new_current_ui != null:
		
		menu_screen_changed.emit(new_current_ui_node_name)
		current_ui = new_current_ui
		new_current_ui.show_screen()
	
func exit_current_screen() -> void:
	current_ui = null
	main_screen.show_screen()

func force_quit_menu() -> void:
	
	if current_ui != null:
		current_ui.hide_screen()
		
	menu_closed.emit()
	if menu_animation:
		menu_animation.play(close_menu_animation)
