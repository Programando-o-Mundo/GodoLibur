extends InteractionArea

signal password_puzzle_solved()
signal show_password_screen(cutcene_texture: CompressedTexture2D, password: String)

@export var background_texture : CompressedTexture2D
@export var password : String

func _ready():
	
	var hud = get_tree().current_scene.get_node("HUD")
	if not hud:
		printerr("ERROR! HUD not found!\n")
		get_tree().quit(1)
		
	show_password_screen.connect(hud.show_password_puzzle)
	hud.correct_password_inputted.connect(player_inputted_correct_password)

func _on_player_interacted(_motion: Vector2) -> void:
	show_password_screen.emit(password, background_texture)
	
func player_inputted_correct_password():
	password_puzzle_solved.emit()
