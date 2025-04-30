extends Node

# Carrega a cena main.tscn
var main_scene = preload("res://cenas/main.tscn")  # Certifique-se de que o caminho está correto

@onready var botao_easy = $Easy  # Referência ao botão Easy
@onready var botao_hard = $Hard  # Referência ao botão Hard
@onready var botao_start = $Button # Referência ao botão Start

var modo = GameMode.get_mode()  # Chama a função na instância

# Função chamada quando a cena é carregada
func _ready():
	# Verifica se os botões foram encontrados corretamente
	if botao_easy != null:
		print("Botão Easy encontrado")
	else:
		print("Erro: Botão Easy não encontrado")

	if botao_hard != null:
		print("Botão Hard encontrado")
	else:
		print("Erro: Botão Hard não encontrado")

	if botao_start != null:
		print("Botão Start encontrado")
	else:
		print("Erro: Botão Start não encontrado")
		
	$AudioStreamPlayer2D.play()

func _on_button_pressed() -> void:
	print("Iniciando o Jogo!")
	# Chama a função que troca para a cena do jogo
	get_tree().change_scene_to_file("res://cenas/main.tscn")

# Função para o botão de modo fácil
func _on_easy_pressed() -> void:
	print("Modo Fácil selecionado")
	GameMode.set_mode("easy")
	print("")
	
# Função para o botão de modo difícil
func _on_hard_pressed() -> void:
	print("Modo Difícil selecionado")
	GameMode.set_mode("hard")
	print("")
