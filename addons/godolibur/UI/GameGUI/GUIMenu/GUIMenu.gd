@tool
extends Control
class_name GUIMenu

signal gui_menu_opened()
signal gui_menu_closed()
signal gui_menu_screen_changed(screen_name)


@export var open_gui_command : StringName = "ui_home"

@export_category("Screens")
@export var screens : Array[SimpleScreen]
@export var main_screen : SimpleScreen :
	set(new_main_screen):
		main_screen = new_main_screen
		if Engine.is_editor_hint():
			update_configuration_warnings()
			
			
@export_category("Animations")
@export var gui_animation : AnimationPlayer
@export var open_menu_animation : String = "open"
@export var close_menu_animation : String = "close"

var current_ui : SimpleScreen
var campaing : Campaing

func _get_configuration_warnings() -> PackedStringArray:
	
	var errors := []
	
	if main_screen == null:
		errors.append("Make sure the GUIMenu has a main screen specified, its necessary!")
		
	return errors

func _ready() -> void:
	
	if Engine.is_editor_hint():
		_tool_ready()
		return
	
	campaing = CampaingOverseer.current_campaing
	
	if not campaing:
		printerr("[%s]: Error! It was not possible to load the campaing node!" % self.name)
	
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

	if event.is_action_pressed(open_gui_command) and campaing.gui_available_to_show():
		
		if current_ui != null:
			current_ui.hide_screen()
			
		else:
			
			if get_tree().paused:
		
				gui_menu_closed.emit()
				play_gui_animation("close")
			else:
				
				gui_menu_opened.emit()
				play_gui_animation("open")
				main_screen.show_screen()
				
func play_gui_animation(animation_name: StringName) -> void:
	
	if gui_animation != null:
		return
		
	if not gui_animation.has_animation(animation_name):
		return
		
	gui_animation.play()
	
func open_screen(new_current_ui_node_name: String) -> void:
	
	var new_current_ui = get_node(new_current_ui_node_name)
	
	if new_current_ui != null:
		
		gui_menu_screen_changed.emit(new_current_ui_node_name)
		current_ui = new_current_ui
		new_current_ui.show_screen()
	
func exit_current_screen() -> void:
	current_ui = null
	main_screen.show_screen()

func force_quit_menu() -> void:
	
	if current_ui != null:
		current_ui.hide_screen()
		
	gui_menu_closed.emit()
	if gui_animation:
		gui_animation.play("close")



