extends CutceneInterface
class_name StaticCutcene

@export var start_at_ready : bool

@export var cutcene_script : GDScript
@export var background : Control
@export var animation_player : AnimationPlayer
	
func play_cutcene(cutcene_texture: CompressedTexture2D = null, script: GDScript = cutcene_script) -> void:
	
	is_active = true
	
	if cutcene_texture:
		background.texture = cutcene_texture
	animation_player.play("show_screen")

	play_script(script)
	
func hide_cutcene() -> void:
	animation_player.play("hide_screen")
	
	await animation_player.animation_finished
	
	cutcene_ended.emit()
	is_active = false
