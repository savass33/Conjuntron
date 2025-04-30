extends Node2D  # Ou o tipo de nó correspondente à sua cena de explosão

@onready var animation_player = $AnimationPlayer  # Referência ao AnimationPlayer que controla a animação

func _ready():
	# Conecta o sinal usando Callable
	animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"))
	$AudioStreamPlayer2D.play()
# Esta função é chamada quando a animação terminar
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "explosion":  # Verifica se a animação finalizada é "explosion"
		queue_free()  # Remove o nó de explosão da cena
