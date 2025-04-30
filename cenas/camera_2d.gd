extends Camera2D

@onready var player = get_parent().get_node("player")  # Acessa o nó player no nível do nó pai
@onready var label_1 = $score  # Acessa a Label1
@onready var label_2 = $pontos  # Acessa a Label2

func _ready():
	# Desativa o movimento vertical da câmera
	offset.y = 0  # Mantém a posição Y fixa da câmera

func _process(delta):
	# Ajusta a posição da câmera apenas no eixo X com base no jogador
	global_position.x = player.global_position.x
	# Fixa a posição vertical da câmera para que não acompanhe o movimento Y
	global_position.y = 0  # Substitua 0 por qualquer valor para ajustar a altura da câmera
	
	# Ajusta a posição X das labels para seguir a posição da câmera, mantendo o Y fixo
	label_1.global_position.x = global_position.x
	label_1.global_position.y = 0
	label_2.global_position.x = global_position.x + 70
	label_2.global_position.y = 0
