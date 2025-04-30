extends Area2D

var explosion_scene = preload("res://cenas/explosion.tscn")
var pergunta_font = preload("res://assetsnew/font/perguntas.ttf")  # Carrega a fonte personalizada

var resposta : int  # Resposta associada ao inimigo
var resposta_label : Label  # Label que vai exibir a resposta
var enemy_index : int  # Índice do inimigo (associado à pergunta/resposta)
var speed = 100           # Velocidade do movimento do inimigo
var move_range_x = 100    # Limite da área de movimento no eixo X (área menor)
var move_range_y = 50     # Limite da área de movimento no eixo Y (área menor)
var direction_x = 1       # Direção inicial no eixo X (1 para direita, -1 para esquerda)
var direction_y = 1       # Direção inicial no eixo Y (1 para baixo, -1 para cima)
var initial_position_x = 0  # Posição inicial no eixo X
var initial_position_y = 0  # Posição inicial no eixo Y
var change_direction_timer = 1.0  # Intervalo de tempo para mudança de direção aleatória
var timer = 0.0
var player_position : Vector2  # Posição do jogador

func _ready():
	add_to_group("enemy")  # Certifica que os inimigos pertencem ao grupo "enemy"
	# Obtém a posição do jogador (presumindo que o jogador está em um nó chamado "Player")
	player_position = get_tree().root.get_node("main/player").global_position

	initial_position_x = global_position.x  # Salva a posição inicial X
	initial_position_y = global_position.y  # Salva a posição inicial Y
	
	# Criação da Label para exibir a resposta
	resposta_label = Label.new()
	resposta_label.text = str(resposta)  # Exibe a resposta
	resposta_label.position = Vector2(0, -50)  # Ajusta a posição da label para não ficar tão próxima do inimigo

	# Aplica a fonte personalizada na label
	var custom_font = preload("res://assetsnew/font/perguntas.ttf")  # Carrega a fonte diretamente
	#resposta_label.add_font_override("font", custom_font)  # Aplica a fonte personalizada

	add_child(resposta_label)  # Adiciona a label ao inimigo

	# Garante que o inimigo não apareça muito perto do jogador
	garantir_distancia_do_jogador()

func garantir_distancia_do_jogador():
	# Calcula uma nova posição para o inimigo que seja ao menos 100 pixels distante do jogador
	var distancia_minima = 100  # Distância mínima de segurança
	while global_position.distance_to(player_position) < distancia_minima:
		# Gera uma posição aleatória dentro dos limites da cena (exemplo de limites: 200 a 800 para X e 100 a 600 para Y)
		global_position = Vector2(randf_range(200, 800), randf_range(100, 600))

func _process(delta):
	# Controla o tempo para mudar a direção do inimigo
	timer -= delta
	if timer <= 0:
		alterar_direcao_aleatoria()  # Altera a direção aleatória
		timer = change_direction_timer  # Reseta o temporizador para o próximo intervalo

func _physics_process(delta):
	# Movimento aleatório horizontal (esquerda/direita)
	global_position.x += speed * direction_x * delta

	# Movimento aleatório vertical (cima/baixo)
	global_position.y += speed * direction_y * delta

	# Limita o movimento no eixo X dentro da área de movimentação
	if global_position.x > initial_position_x + move_range_x:
		direction_x = -1  # Inverte a direção para a esquerda
	elif global_position.x < initial_position_x - move_range_x:
		direction_x = 1  # Inverte a direção para a direita

	# Limita o movimento no eixo Y dentro da área de movimentação
	if global_position.y > initial_position_y + move_range_y:
		direction_y = -1  # Inverte a direção para cima
	elif global_position.y < initial_position_y - move_range_y:
		direction_y = 1  # Inverte a direção para baixo
# Função para alterar a direção aleatoriamente
func alterar_direcao_aleatoria():
	# Atribui direções aleatórias aos eixos X e Y
	direction_x = randf_range(-1, 1)  # Direção aleatória no eixo X
	direction_y = randf_range(-1, 1)  # Direção aleatória no eixo Y

	# As direções aleatórias não podem ser zero para garantir movimento
	if direction_x == 0:
		direction_x = 1  # Garantir que a direção seja sempre 1 ou -1
	if direction_y == 0:
		direction_y = 1  # Garantir que a direção seja sempre 1 ou -1

# Função chamada quando o inimigo é atingido pelo laser
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("laser"):  # Verifica se o corpo colidido é o laser
		body.queue_free()  # Remove o laser da cena
		spawn_explosion()  # Instancia a explosão
		# Chama a função de verificação da resposta na cena principal
		if is_instance_valid(get_tree().root.get_node("main")):
			get_tree().root.get_node("main").check_answer(resposta)  # Passa somente a resposta
		queue_free()  # Remove o inimigo após a explosão

# Função para instanciar a explosão na posição do inimigo
func spawn_explosion():
	var explosion_instance = explosion_scene.instantiate()
	explosion_instance.global_position = global_position  # Posição global do inimigo
	get_tree().current_scene.add_child(explosion_instance)  # Adiciona a explosão à cena principal
