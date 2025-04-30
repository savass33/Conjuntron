extends Area2D

var explosion_scene = preload("res://cenas/explosion.tscn")
var resposta = 0  # Resposta associada ao inimigo

var speed = 100           # Velocidade do movimento do inimigo
var move_range_x = 200    # Limite da área de movimento no eixo X
var move_range_y = 100    # Limite da área de movimento no eixo Y
var direction_x = 1       # Direção inicial no eixo X (1 para direita, -1 para esquerda)
var direction_y = 1       # Direção inicial no eixo Y (1 para baixo, -1 para cima)
var initial_position_x = 0  # Posição inicial no eixo X
var initial_position_y = 0  # Posição inicial no eixo Y

func _ready():
	initial_position_x = global_position.x  # Salva a posição inicial X
	initial_position_y = global_position.y  # Salva a posição inicial Y

func _physics_process(delta):
	# Movimento horizontal (esquerda/direita)
	global_position.x += speed * direction_x * delta

	# Movimento vertical (cima/baixo)
	global_position.y += speed * direction_y * delta

	# Verifica se o inimigo atingiu o limite de movimentação no eixo X
	if global_position.x > initial_position_x + move_range_x:
		direction_x = -1  # Inverte a direção para a esquerda
	elif global_position.x < initial_position_x - move_range_x:
		direction_x = 1  # Inverte a direção para a direita

	# Verifica se o inimigo atingiu o limite de movimentação no eixo Y
	if global_position.y > initial_position_y + move_range_y:
		direction_y = -1  # Inverte a direção para cima
	elif global_position.y < initial_position_y - move_range_y:
		direction_y = 1  # Inverte a direção para baixo

# Função chamada quando o inimigo é atingido pelo laser
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("laser"):  # Verifica se o corpo colidido é o laser
		body.queue_free()  # Remove o laser da cena
		spawn_explosion()  # Instancia a explosão
		# Chama a função de verificação da resposta na cena principal
		get_tree().root.get_node("main").check_answer(resposta)
		queue_free()  # Remove o inimigo após a explosão

# Função para instanciar a explosão na posição do inimigo
func spawn_explosion():
	var explosion_instance = explosion_scene.instantiate()
	explosion_instance.global_position = global_position  # Posição global do inimigo
	get_tree().current_scene.add_child(explosion_instance)  # Adiciona a explosão à cena principal
