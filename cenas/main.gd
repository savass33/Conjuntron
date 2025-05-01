extends Node2D

@onready var pergunta_labels = [$pergunta1, $pergunta2, $pergunta3, $pergunta4, $pergunta5, $pergunta6, $pergunta7, $pergunta8, $pergunta9, $pergunta10]
@onready var pontos_label = $Camera2D/pontos
@onready var Player = $player
@onready var music_player = $AudioStreamPlayer

var modo = GameMode.get_mode()
var pontos_meta = 1
var perguntas = []
var respostas = []
var pontos = 0
var inimigos = []
var correct_answers = []
var questao_atual = 0
var num_perguntas = 10
var velocidade_jogador = 200

func _ready():
	gerar_perguntas()
	spawn_enemies()
	$player/AnimationPlayer.play("animation_Player")
	$enemy/AnimationEnemy1.play("animationEnemy")
	alteraPontos()
	var audio_stream = preload("res://MathRun Files/fast-chiptune-for-gaming-videos-253097.mp3")
	audio_stream.loop = true
	music_player.stream = audio_stream
	music_player.play()

func gerar_perguntas():
	perguntas.clear()
	respostas.clear()
	correct_answers.clear()
	for i in range(num_perguntas):
		var pergunta = ""
		var resposta = ""
		match i:
			0:
				pergunta = "Qual elemento é conjunto dos números naturais?"
				resposta = "5"
			1:
				pergunta = "Qual conjunto inclui apenas números negativos?"
				resposta = "Inteiros"
			2:
				pergunta = "Qual elemento pertence ao conjunto dos números racionais?"
				resposta = "1/4"
			3:
				pergunta = "Qual é a imagem da função f(x)=x+2 para x=1?"
				resposta = "3"
			4:
				pergunta = "(2,3) é um exemplo de?"
				resposta = "Par ordenado"
			5:
				pergunta = "Se A={1,2} e B={3,4}, quantos pares em AxB?"
				resposta = "4"
			6:
				pergunta = "Sequência: 2, 4, 6, 8,... Qual o próximo?"
				resposta = "10"
			7:
				pergunta = "Conjunto vazio é representado por?"
				resposta = "∅ ou {}"
			8:
				pergunta = "A função f(x) = x² é um exemplo de que tipo de função?"
				resposta = "Quadrática"
			9:
				pergunta = "x ∈ A significa?"
				resposta = "x pertence a A"
		perguntas.append(pergunta)
		respostas.append(resposta)
		correct_answers.append(resposta)
	atualizar_pergunta()

func atualizar_pergunta():
	if questao_atual < num_perguntas:
		var texto = perguntas[questao_atual]
		if texto.length() > 50:
			var meio = texto.find(" ", texto.length() / 2)
			if meio != -1:
				texto = texto.substr(0, meio) + "\n" + texto.substr(meio + 1)
		pergunta_labels[questao_atual].text = texto
		pergunta_labels[questao_atual].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		pergunta_labels[questao_atual].set_size(Vector2(600, 80))
	else:
		encerrar_jogoVitória()
	$apareceQuestao.play()

func alteraPontos():
	if modo == "hard":
		pontos_meta = 9000
	else:
		pontos_meta = 4500
	$Label/metaPontos.text = str(pontos_meta)

func gerar_inimigos_da_proxima_questao():
	if questao_atual < num_perguntas:
		questao_atual += 1
		atualizar_pergunta()
		spawn_enemies()
	else:
		encerrar_jogoVitória()

func spawn_enemies():
	if questao_atual >= num_perguntas:
		encerrar_jogoVitória()
		return
	destruir_inimigos()
	inimigos.clear()
	var respostas_usadas = {}
	var positions = []
	var y0 = pergunta_labels[questao_atual].global_position.y + 50
	var x0 = pergunta_labels[questao_atual].global_position.x + 400
	for i in range(3):
		positions.append(Vector2(x0, y0 + i * 60))
	positions.shuffle()
	var certa = correct_answers[questao_atual]
	respostas_usadas[certa] = true
	spawn_enemy(positions[0], certa)

	# Gerar alternativas incorretas coerentes com a pergunta
	var alternativas_possiveis = [
		["-10", "π", "√-7"],
		["Irracionais", "Racionais", "Reais"],
		["1/4", "π", "√2"],
		["2", "4", "5"],
		["Par ordenado", "Dizima periódica", "Raíz Quadrada"],
		["2", "6", "8"],
		["12", "14", "16"],
		["vazio", "sem elementos", "nulo"],
		["Constante", "Afim", "Exponencial"],
		["x está em A", "x dentro de A", "x existe em A"]
	]
	var alternativas = alternativas_possiveis[questao_atual]
	for i in range(1, 3):
		var incorreta = null
		while incorreta == null:
			var tentativa = alternativas.pick_random()
			if tentativa != certa and not respostas_usadas.has(tentativa):
				incorreta = tentativa
		respostas_usadas[incorreta] = true
		spawn_enemy(positions[i], incorreta)

func spawn_enemy(pos: Vector2, resposta):
	var enemy = preload("res://cenas/enemy.tscn").instantiate()
	enemy.global_position = pos
	enemy.resposta = resposta
	call_deferred("add_child", enemy)
	inimigos.append(enemy)

func check_answer(player_answer):
	if player_answer == correct_answers[questao_atual]:
		add_pontos(1000)
		destruir_inimigos()
		incrementar_velocidade_jogador()
		$acertaQuestao.play()
	else:
		add_pontos(-500)
		reduzir_velocidade_jogador()

func incrementar_velocidade_jogador():
	Player.SPEED += 25

func reduzir_velocidade_jogador():
	Player.SPEED -= 25

func add_pontos(valor):
	pontos += valor
	pontos_label.text = str(pontos)

func destruir_inimigos():
	for inimigo in inimigos:
		if is_instance_valid(inimigo):
			inimigo.queue_free()
	inimigos.clear()

func _process(delta):
	if pontos >= pontos_meta:
		encerrar_jogoVitória()
	elif Player.SPEED <= 0:
		encerrar_jogoDerrota()

func encerrar_jogoVitória():
	var win_scene = load("res://cenas/win_screen.tscn").instantiate()
	win_scene.set_score(pontos)
	get_tree().root.add_child(win_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = win_scene

func encerrar_jogoDerrota():
	get_tree().change_scene_to_file("res://cenas/game_over.tscn")

func _on_area_1_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_2_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_3_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_4_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_5_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_6_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_7_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_8_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_9_body_entered(body):
	if body.is_in_group("player"):
		gerar_inimigos_da_proxima_questao()
	elif body.is_in_group("laser"):
		body.queue_free()

func _on_area_win_body_entered(body: Node2D) -> void:
	if pontos >= pontos_meta:
		encerrar_jogoVitória()
	else:
		encerrar_jogoDerrota()
