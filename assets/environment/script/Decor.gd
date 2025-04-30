extends Node2D

@export var speed: int = 150
@export var _texture: Texture2D

func _ready():
	$Sprite2D.texture = _texture
	$Sprite2.texture = _texture

func _process(delta):
	position.x -= speed * delta
	if global_position.x < -get_viewport().size.x:
		position.x = 0
