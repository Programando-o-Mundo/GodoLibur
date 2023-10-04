extends Node
class_name CutceneScript

signal next_step_requested()
signal dialog_closed(option)
signal show_dialog_box(properties)

var cutcene : CutceneInterface = null
var is_active : bool = false

func _ready():
	
	var hud = CampaingOverseer.current_campaing.get_hud()
	
	if not hud:
		printerr("[%s] ERROR! GUI not found!" % self.name)
		return  
		
	show_dialog_box.connect(hud.show_dialog_box_text)
	hud.dialog_closed.connect(on_dialog_closed)

func play(hide_cutcene: Callable):
	
	is_active = true
	
	await next_step_requested
	
	hide_cutcene.call()
	
func on_dialog_closed(option: String) -> void:
	dialog_closed.emit(option)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept") and is_active:
		next_step_requested.emit()
