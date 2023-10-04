extends Control
class_name GameGUI

signal gui_opened()
signal gui_closed()
signal gui_screen_changed(screen_name)

@export var open_gui_command : StringName = "ui_home"
@export var screens : Array[SimpleUI]
@export var main_screen : SimpleUI
@export var gui_animation : AnimationPlayer

var current_ui : SimpleUI
var campaing : Campaing

func _ready() -> void:
	
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


func _input(event : InputEvent ) -> void:

	if event.is_action_pressed(open_gui_command) and campaing.gui_available_to_show():
		
		if current_ui != null:
			current_ui.hide_screen()
			
		else:
			
			if get_tree().paused:
		
				gui_closed.emit()
				gui_animation.play("close_menu")
			else:
				
				gui_opened.emit()
				main_screen.update_time(campaing.get_current_time())
				gui_animation.play("open_menu")
				main_screen.show_screen()
	
func open_screen(new_current_ui_node_name: String) -> void:
	
	var new_current_ui = get_node(new_current_ui_node_name)
	
	if new_current_ui != null:
		
		gui_screen_changed.emit(new_current_ui_node_name)
		current_ui = new_current_ui
		new_current_ui.show_screen()
	
func exit_current_screen() -> void:
	current_ui = null
	main_screen.show_screen()

func force_quit_menu() -> void:
	
	if current_ui != null:
		current_ui.hide_screen()
		
	gui_closed.emit()
	gui_animation.play("close_menu")



