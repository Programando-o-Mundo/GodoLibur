# An rpg style dialog system 
extends Control
class_name DialogBox

# Signal for when the dialog ends, and send option that
# the player has chosen
signal dialog_ended(option)

# Typing speed for the dialog
@export var typing_speed : = 0.01 # (float,0.05,0.1)
@export var character_head_texture_default : Texture2D

# Control the possible modes for exhibition and interaction in the 
# dialog system
enum gui {
	dialog,
	choice
}

### Nodes connected to script ### 

# VboxContainer used to alternate the position of the 
# dialog box between, center and middle
@onready var vertical_space = $"VerticalSpace"

# All UiWindowBoxes
@onready var large_dialog_box   = $"VerticalSpace/CharacterDialog/LargeDialogBox"
@onready var small_dialog_box   = $"VerticalSpace/CharacterDialog/SmallDialogBox"
@onready var character_name_box = $"VerticalSpace/CharacterName"

# Dialog elements
@onready var dialog_text = $"VerticalSpace/CharacterDialog/DialogAndButtons/VerticalBox/DialogText"
@onready var option1 	= $"VerticalSpace/CharacterDialog/DialogAndButtons/VerticalBox/Option1"
@onready var option2 	= $"VerticalSpace/CharacterDialog/DialogAndButtons/VerticalBox/Option2"

# Character characteristics
@onready var character_head = $"VerticalSpace/CharacterDialog/CharacterHead"
@onready var character_name = $"VerticalSpace/CharacterName/TextMargin/CharacterNameText"

# Animation elements
@onready var animation = $"MenuAnimation"
@onready var letter_timer = $"LetterTimer"
@onready var arrow        = $"VerticalSpace/CharacterDialog/Arrow"

### Regular data type variables ### 

var started : bool
var talking : bool

var current_mode   = gui.dialog
var chosen_option : = ""

var content : Array
var page : = 0

# Control the type of arrow animation (LargeDialogBox and SmallDialogBox)
var arrow_animation_name : String

func _ready() -> void:
	
	option1.modulate.a = 0
	option2.modulate.a = 0
	
	started = false
	talking = false
	
	# Setting the default dialog character to the 
	# main character
	character_name.text    = "Hiroshi"
	
	if character_head_texture_default:
		character_head.texture = character_head_texture_default
	
	# Most used alignment in the game (bottom)
	vertical_space.alignment = VERTICAL_ALIGNMENT_BOTTOM
	
# Get the player choice, and end the current iteration
# of the dialog process
func _button_pressed(text : String) -> void:
	chosen_option = text 
	self.animation.play("End")
	
func _process(_delta : float) -> void:
	
	# Check every frame if there is still dialog to be exhibited in the current page
	if not talking:
		return 
		
	if dialog_text.visible_characters == dialog_text.get_total_character_count() and talking:
		_end_current_page()

func _input(event : InputEvent) -> void:

	if _next_dialog_key_pressed(event) and started:
		
		# Skip the current line of dialog
		if talking:
			dialog_text.visible_characters = dialog_text.get_total_character_count()
			_end_current_page()
		else:
			
			# Logic for iterating through multiple dialogs
			# in the "gui.dialog" option
			if current_mode == gui.dialog:
				if page < content.size() - 1:
					_next_page()
				else:
					self.animation.play("End")

"""
# Inform through the user interface, that
# the current page of dialog has ended, and
# that he needs select an option(gui.choice) 
# or that he needs to confirm to go to the next screen
"""
func _end_current_page() -> void:
	talking = false
	
	if current_mode == gui.dialog:
		arrow.visible = true
		
	elif current_mode == gui.choice:
		
		option1.set_button_text(content[1])
		option2.set_button_text(content[2])
		
		animation.play("Show options")
		
	letter_timer.stop()
	
"""
Set the @VerticalSpace alignment to either:
0 - Top
1 - Center
2 - Bottom
"""
func set_vertical_alignment(vertical_alignment : int) -> void:
	vertical_space.alignment = vertical_alignment
	
"""
Pro-tip: by setting the character name as an empty string, you
will set the dialog into "Narrator mode" were no portrait 
will be show.
"""
func set_character_name(new_character_name : String) -> void:
	self.character_name.text = new_character_name
	

func set_character_portrait(character_head_texture: Texture2D) -> void:
	self.character_head.texture = character_head_texture
	
"""
# Start the dialog sequence. From here, there are
# two braching possibilities for the "gui_mode"
#
# gui.dialog - "text" will be a sequence of 
# Strings, indicating the pages that needs to be showed
# on the screen
#
# gui.choice - "text" will be a array of String
# with only three places
# 0 - The question
# 1 - First choice
# 2 - Second choice
"""
func show_dialog(text : Array ,gui_mode : gui = gui.dialog) -> void:

	"""Set the content and the gui for dialog"""
	self.current_mode = gui_mode
	self.content      = [] + text # create a copy of "content"
	
	if current_mode == gui.choice:
		option1.pressed.connect(_button_pressed)
		option2.pressed.connect(_button_pressed)
	
	"""
	# An empty "character_name" means that this dialog
	# will be set to "Narrator mode", meaning that a 
	# smaller box will be showed, and the character
	# characteristics will be invisible
	"""
	if(character_name.text.strip_edges().is_empty()):
		
		large_dialog_box.visible   = false
		character_name_box.visible = false
		character_head.visible     = false
		
		"""Setting the type of arrow animation"""
		arrow_animation_name = "ArrowAnimationSmall"

	# In here, everything will be showed, except the narrator box
	else:
		
		small_dialog_box.visible = false
		large_dialog_box.visible   = true
		character_name_box.visible = true
		character_head.visible     = true
		
		# Calculate the minimum size for character
		# name box.
		var new_character_name = " " + self.character_name.text.strip_edges(true,true) + " " 
		character_name.text = new_character_name
		#var character_name_length = character_name.get_theme_font("font").get_string_size(name)
		
		#character_name.size = character_name_length
		
		# Setting the type of arrow animation
		arrow_animation_name = "ArrowAnimationLarge"
	
	# Start animation(Fade In)
	animation.play("Start")
	
	await animation.animation_finished
	
	started = true
	talking = true
	
	letter_timer.wait_time = typing_speed
	letter_timer.start()
	
	dialog_text.visible_characters = 0
	animation.play(arrow_animation_name)
	_add_dialog()

# Display next page
func _next_page() -> void:
	page += 1
	
	_add_dialog()
	letter_timer.start()
	
	talking = true
	arrow.visible = false


# Adding next page of dialog to the dialog text
func _add_dialog() -> void: 
	
	dialog_text.text += content[page]

"""
# Dialog has finished. Reset the dialog box for future use.
# Emit the signal that the current dialog has
# ended, along with the choice that the player chose
"""
func _on_end_animation_end() -> void:
	started = false
	content.clear()
	
	page             = 0
	dialog_text.text = ""
	current_mode     = gui.dialog
	
	if current_mode == gui.choice:
		option1.pressed.disconnect(_button_pressed)
		option2.pressed.disconnect(_button_pressed)
	
	dialog_ended.emit(chosen_option)

"""
# Function to call when, the animation that shows
# the button with options to the player has ended.
# It will grab the focus of the first option button,
# so that the player can interact with the options with
# the keyboard
"""
func _on_show_options_animation_end() -> void:
	$"VerticalSpace/CharacterDialog/DialogAndButtons/VerticalBox/Option1".grab_focus()

# Display the next character of the text
func _on_LetterTimer_timeout() -> void:
	dialog_text.visible_characters += 1
	
# Check if the user pressed the next dialog key
func _next_dialog_key_pressed(event : InputEvent) -> bool:
	return (event is InputEventMouseButton and event.is_pressed()) or (event.is_action_pressed("game_interact"))
