extends CharacterBody2D

var SPEED = 100
var top_limit = 50
var bottom_limit = 600
var left_limit = 0
var right_limit = 9999999999999
var CONSTANT_SPEED = 70

@onready var timer_disparo = $timerDisparo2
var pode_disparar = true

var laser_scene = preload("res://cenas/laser.tscn")
var modo = GameMode.get_mode()

func _ready():
	add_to_group("player")
	collision_layer = 1  # Player na camada 1
	collision_mask = 2   # O player não deve colidir com o laser na camada 2

	if GameMode.get_mode() == "easy":
		SPEED = 50
	elif GameMode.get_mode() == "hard":
		SPEED = 100

func _physics_process(delta: float) -> void:
	velocity.x = SPEED  # Movimento constante no eixo X
	
	# Controle no eixo Y
	var direction_y := Input.get_axis("move_up", "move_down")
	velocity.y = direction_y * SPEED if direction_y != 0 else move_toward(velocity.y, 0, SPEED * delta)

	# Aplica o movimento
	move_and_slide()
	position.y = clamp(position.y, top_limit, bottom_limit)
	position.x = clamp(position.x, left_limit, right_limit)

	if Input.is_action_just_pressed("shoot") and pode_disparar == true:
		shoot_laser()

func shoot_laser():
	var laser = laser_scene.instantiate()
	laser.position = position
	get_tree().current_scene.add_child(laser)
	$AudioStreamPlayer2D.play()
	pode_disparar = false
	timer_disparo.start()


func _on_timer_disparo_2_timeout() -> void:
	pode_disparar = true
