extends Control
class_name PasswordInputter

signal password_inputted(is_password_correct)

# HboxContainer storing all buttons
@onready var button_container = $InputBox/PasswordBox/Margin/ButtonContainers
@onready var animation        = $Animation
@onready var background       = $Background

# Button used for typing the password
@export var button_scene: PackedScene

var background_texture: CompressedTexture2D : set = _set_texture

# Result for the puzzle
var password: String : set = _set_password
		
var password_entered_correctly : = false
		
var first_button : PasswordCharacter

func _set_password(new_password: String) -> void:
	"""
	# The scene must insert all buttons in the button_container, this is done
	# by using the length of the password, as a counter for the number of buttons 
	# that must be added to the scene
	"""	
	password = new_password
	
	if button_container.get_child_count() > 0:
		delete_children(button_container)
		
	for i in range(len(password)):
	
		var new_button : PasswordCharacter = button_scene.instantiate()
		
		button_container.add_child(new_button)
		
		if i == 0:
			first_button = new_button
			
		var _err = new_button.pressed.connect(process_password)

func _set_texture(texture: CompressedTexture2D) -> void:
	background_texture = texture
	background.texture = texture

func show_screen() -> void:
	
	if not password_entered_correctly:
		animation.play("show_screen")
		
		await animation.animation_finished
		
		first_button.grab_button_focus()
	
# Retrieve the text from all buttons, reset button text,
# then send signal if the correct password was entered
func process_password() -> void:
	
	var player_input : String = ""
	
	var button_container_children = button_container.get_children()

	for button in button_container_children:
		player_input += button.button_text()
		button.reset_button_text()
	
	animation.play("hide_screen")
	
	await animation.animation_finished
	
	password_inputted.emit(player_input == password)	

func delete_children(node: Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
