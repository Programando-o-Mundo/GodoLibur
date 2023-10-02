extends Button
class_name PasswordCharacter

const numbers = [0,1,2,3,4,5,6,7,8,9]

@onready var ui_arrow = $UiArrow

var current_number_index : = 0
var focused              : = false

func _ready() -> void:
	update_text()

func _input(event : InputEvent ) -> void:
	
	if not focused:
		return
		
	if event.is_action_pressed("ui_down"):
		if current_number_index == 0:
			current_number_index = numbers.size() - 1
		else:
			current_number_index -= 1
			
		update_text()
	
	if event.is_action_pressed("ui_up"):
		if current_number_index == numbers.size() - 1:
			current_number_index = 0
		else:
			current_number_index += 1
		
		update_text()

func update_text() -> void:
	text = str(numbers[current_number_index])

func reset_button_text() -> void:
	current_number_index = 0
	update_text()

func _on_focus_entered():
	ui_arrow.play_animation()
	focused = true

func _on_focus_exited():
	ui_arrow.stop_animation()
	focused = false
