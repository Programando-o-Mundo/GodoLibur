extends InteractionArea

signal show_cutcene(cutcene_texture: CompressedTexture2D)

@export var background_texture : CompressedTexture2D
@export var cutcene_script : GDScript

func _ready():
	var hud = get_tree().current_scene.get_node("HUD")
	if not hud:
		printerr("ERROR! HUD not found!\n")
		get_tree().quit(1)
		
	show_cutcene.connect(hud.show_static_cutcene)

func _on_player_interacted(_motion : Vector2) -> void:
	show_cutcene.emit(background_texture,cutcene_script)
