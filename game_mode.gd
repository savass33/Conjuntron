extends Node

var current_mode = "easy"  # Valor padrão

# Função para definir o modo de jogo
func set_mode(mode: String) -> void:
	current_mode = mode
	print("Modo atual:" + current_mode)

# Função para obter o modo de jogo
func get_mode() -> String:
	return current_mode
