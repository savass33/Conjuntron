extends Node

@onready var labelScore = $labelScore
var pontos_recebidos = 0

func _ready():
	labelScore.text = str(pontos_recebidos)  # Mostra os pontos ao carregar
	$winTheme.play()

func set_score(pontos):
	pontos_recebidos = pontos  # Armazena os pontos

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/main.tscn")
