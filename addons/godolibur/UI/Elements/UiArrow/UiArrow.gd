extends TextureRect

@onready var animator = $Animation

func play_animation() -> void:
	animator.play("Blink")
	
func stop_animation() -> void:
	animator.stop()
	self.modulate.a = 0
