extends Node2D

@onready var pergunta_labels = [$pergunta1, $pergunta2, $pergunta3, $pergunta4, $pergunta5, $pergunta6, $pergunta7, $pergunta8, $pergunta9, $pergunta10]
@onready var pontos_label = $Camera2D/pontos
@onready var Player = $player
@onready var music_player = $AudioStreamPlayer  # Referência ao nó AudioStreamPlayer

var modo = GameMode.get_mode()  # Chama a função na instância

var pontos_meta = 1  # Pontos necessários para vencer
var perguntas = []
var respostas = []
var pontos = 0
var inimigos = []
var correct_answers = []
var questao_atual = 0
var num_perguntas = 10  # Número de perguntas
var velocidade_jogador = 200  # Velocidade do jogador, usada para alterar no modo difícil

# Função chamada quando a cena é carregada
func _ready():
	gerar_perguntas()
	spawn_enemies()
	$player/AnimationPlayer.play("animation_Player")
	$enemy/AnimationEnemy1.play("animationEnemy")
	alteraPontos()
	var audio_stream = preload("res://MathRun Files/fast-chiptune-for-gaming-videos-253097.mp3")  # Carrega o áudio
	audio_stream.loop = true  # Ativa o loop no AudioStream
	music_player.stream = audio_stream  # Atribui o áudio ao player
	music_player.play()  # Começa a tocar a música



# Função para gerar perguntas e respostas
func gerar_perguntas():
	perguntas.clear()
	respostas.clear()
	correct_answers.clear()

	# Gerando as perguntas de forma dinâmica, aumentando a dificuldade a cada questão
	for i in range(num_perguntas):
		var num1 = randi_range(1, 10 + i)  # Aumenta a dificuldade com base na questão
		var num2 = randi_range(1, 10 + i)
		var resposta = 0

		# Variando as operações conforme a questão
		if i < 3:
			resposta = num1 + num2
			perguntas.append(str(num1) + " + " + str(num2) + " = ?")
		elif i < 6:
			resposta = num1 - num2
			perguntas.append(str(num1) + " - " + str(num2) + " = ?")
		else:
			resposta = num1 * num2
			perguntas.append(str(num1) + " * " + str(num2) + " = ?")

		respostas.append(resposta)
		correct_answers.append(resposta)

	atualizar_pergunta()

# Atualiza a pergunta
func atualizar_pergunta():
	if questao_atual < num_perguntas:
		pergunta_labels[questao_atual].text = perguntas[questao_atual]
	else:
		encerrar_jogoVitória()
	$apareceQuestao.play()

func alteraPontos():
	if GameMode.get_mode() == "hard":
		pontos_meta = 9000
		$Label/metaPontos.text = str(pontos_meta)
	else:
		pontos_meta = 4500
		$Label/metaPontos.text = str(pontos_meta)

# Gera inimigos para a próxima questão
func gerar_inimigos_da_proxima_questao():
	if questao_atual < num_perguntas:
		questao_atual += 1
		atualizar_pergunta()
		spawn_enemies()
	else:
		encerrar_jogoVitória()

# Função que gera inimigos
func spawn_enemies():
	if questao_atual >= num_perguntas:
		encerrar_jogoVitória()
		return
		
	destruir_inimigos()
	inimigos.clear()
	var respostas_usadas = {}
	var positions = []
	var start_y = pergunta_labels[questao_atual].global_position.y + 50
	var start_x = pergunta_labels[questao_atual].global_position.x + 400
	var y_offset = 60

	for i in range(3):
		var position = Vector2(start_x, start_y + (y_offset * i))
		positions.append(position)
	
	positions.shuffle()
	var resposta_correta = correct_answers[questao_atual]
	respostas_usadas[resposta_correta] = true
	spawn_enemy(positions[0], resposta_correta)
	
	for i in range(1, 3):
		var resposta_incorreta = null
		while resposta_incorreta == null:
			var tentativa = randi_range(-10, 20)
			if tentativa != resposta_correta and not respostas_usadas.has(tentativa):
				resposta_incorreta = tentativa
		respostas_usadas[resposta_incorreta] = true
		spawn_enemy(positions[i], resposta_incorreta)

# Função para instanciar o inimigo
func spawn_enemy(position: Vector2, resposta: int):
	var enemy_instance = preload("res://cenas/enemy.tscn").instantiate()
	enemy_instance.global_position = position
	enemy_instance.resposta = resposta
	call_deferred("add_child", enemy_instance)
	inimigos.append(enemy_instance)

# Função para verificar a resposta do jogador
func check_answer(player_answer: int):
	if player_answer == correct_answers[questao_atual]:
		add_pontos(1000)
		destruir_inimigos()
		incrementar_velocidade_jogador()
		$acertaQuestao.play()
	else:
		add_pontos(-500)
		reduzir_velocidade_jogador()

# Aumento de velocidade do jogador
func incrementar_velocidade_jogador():
	Player.SPEED += 25

# Diminuição de velocidade do jogador
func reduzir_velocidade_jogador():
	Player.SPEED -= 25

# Adicionar pontos ao jogador
func add_pontos(valor: int):
	pontos += valor
	pontos_label.text = str(pontos)

# Função para destruir os inimigos
func destruir_inimigos():
	for inimigo in inimigos:
		if inimigo and is_instance_valid(inimigo):
			inimigo.queue_free()
	inimigos.clear()

# Função de controle do jogo
func _process(delta):
	if pontos >= pontos_meta:
		encerrar_jogoVitória()
	elif Player.SPEED <= 0:
		encerrar_jogoDerrota()

# Encerramento do jogo por vitória
func encerrar_jogoVitória():
	print("Você venceu!")
	var win_scene = load("res://cenas/win_screen.tscn").instantiate()
	win_scene.set_score(pontos)
	get_tree().root.add_child(win_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = win_scene

# Encerramento do jogo por derrota
func encerrar_jogoDerrota():
	print("Você perdeu!")
	get_tree().change_scene_to_file("res://cenas/game_over.tscn")

func _on_area_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_4_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_5_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_6_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_7_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_8_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_9_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()  # Destroi o laser ao colidir

func _on_area_win_body_entered(body: Node2D) -> void:
	print("Jogo finalizado")
	# Verifica se o modo de jogo é "hard" e se o jogador alcançou a pontuação necessária
	if GameMode.get_mode() == "hard" and pontos >= 9000:
		print("Vitória no modo hard")
		encerrar_jogoVitória()  # Cena de vitória
	# Verifica se o modo de jogo é "easy" e se o jogador alcançou a pontuação necessária
	elif GameMode.get_mode() == "easy" and pontos >= 4500:
		print("Vitória no modo easy")
		encerrar_jogoVitória()  # Cena de vitória
	else:
		print("Game Over")
		encerrar_jogoDerrota()  # Game Over
