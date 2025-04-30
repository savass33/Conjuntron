extends Node2D

var SPEED = 400

# Adicione uma função para monitorar as colisões
func _on_Laser_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Laser colidiu com o player, o que não deveria acontecer.")
		# Aqui podemos tentar evitar que o laser se mova ao atingir o player
		queue_free()

func _process(delta: float) -> void:
	position.x += SPEED * delta
	if position.x > 40000:
		queue_free()
