extends Area2D

var explosion_scene = preload("res://cenas/explosion.tscn")
var pergunta_font = preload("res://assetsnew/font/perguntas.ttf")  # Fonte personalizada

var resposta  # Agora aceita qualquer tipo (int, string, etc.)
var resposta_label : Label  # Label que exibe a resposta
var enemy_index : int
var speed = 100
var move_range_x = 100
var move_range_y = 50
var direction_x = 1
var direction_y = 1
var initial_position_x = 0
var initial_position_y = 0
var change_direction_timer = 1.0
var timer = 0.0
var player_position : Vector2

func _ready():
	add_to_group("enemy")
	player_position = get_tree().root.get_node("main/player").global_position

	initial_position_x = global_position.x
	initial_position_y = global_position.y
	
	# Cria e exibe a resposta como texto
	resposta_label = Label.new()
	resposta_label.text = str(resposta)
	resposta_label.position = Vector2(0, -50)

	# Aplica a fonte personalizada
	var custom_font = preload("res://assetsnew/font/perguntas.ttf")  # Carrega a fonte diretamente
	#resposta_label.add_font_override("font", custom_font)  # Aplica a fonte personalizada

	add_child(resposta_label)
	garantir_distancia_do_jogador()

func garantir_distancia_do_jogador():
	var distancia_minima = 100
	while global_position.distance_to(player_position) < distancia_minima:
		global_position = Vector2(randf_range(200, 800), randf_range(100, 600))

func _process(delta):
	timer -= delta
	if timer <= 0:
		alterar_direcao_aleatoria()
		timer = change_direction_timer

func _physics_process(delta):
	global_position.x += speed * direction_x * delta
	global_position.y += speed * direction_y * delta

	if global_position.x > initial_position_x + move_range_x:
		direction_x = -1
	elif global_position.x < initial_position_x - move_range_x:
		direction_x = 1

	if global_position.y > initial_position_y + move_range_y:
		direction_y = -1
	elif global_position.y < initial_position_y - move_range_y:
		direction_y = 1

func alterar_direcao_aleatoria():
	direction_x = randf_range(-1, 1)
	direction_y = randf_range(-1, 1)

	if direction_x == 0:
		direction_x = 1
	if direction_y == 0:
		direction_y = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("laser"):
		body.queue_free()
		spawn_explosion()
		if is_instance_valid(get_tree().root.get_node("main")):
			get_tree().root.get_node("main").check_answer(resposta)
		queue_free()

func spawn_explosion():
	var explosion_instance = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	get_tree().current_scene.add_child(explosion_instance)
