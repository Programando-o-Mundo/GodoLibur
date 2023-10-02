extends Control
class_name GameGUI

signal menu_opened()
signal menu_closed()

@export var screens : Array[SimpleUI]
@export var gui_animation : AnimationPlayer

var current_ui : SimpleUI
var campaing : CampaingHandler
var main_screen : Control

func _ready() -> void:
	
	campaing = get_tree().current_scene
	if not campaing:
		printerr("[%s]: Error! It was not possible to load the campaing node!" % self.name)
	
	for screen in screens:
		screen.visible = false 
		
		screen.exit_screen.connect(exit_current_screen)
		screen.force_quit.connect(force_quit_menu)
		
		if screen.main_screen:
			main_screen = screen
		
	if main_screen != null:
		main_screen.open_screen.connect(open_screen)


func _input(event : InputEvent ) -> void:

	if event.is_action_pressed("ui_home") and not campaing.in_cutcene and not campaing.in_dialog and not campaing.is_player_in_pursuit():
		
		if current_ui != null:
			current_ui.hide_screen()
			
		else:
			
			if get_tree().paused:
		
				menu_closed.emit()
				gui_animation.play("close_menu")
			else:
				menu_opened.emit()
				main_screen.update_time(campaing.get_current_time())
				gui_animation.play("open_menu")
				main_screen.show_screen()
	
func open_screen(new_current_ui_node_name: String) -> void:
	
	var new_current_ui = get_node(new_current_ui_node_name)
	
	if new_current_ui != null:
		current_ui = new_current_ui
		new_current_ui.show_screen()
	
func exit_current_screen() -> void:
	current_ui = null
	main_screen.show_screen()

func force_quit_menu() -> void:
	
	if current_ui != null:
		current_ui.hide_screen()
		
	menu_closed.emit()
	gui_animation.play("close_menu")



