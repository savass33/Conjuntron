extends Area2D

@export var is_enemy: bool = false
@export var move_speed: int = 350

func _ready():
	$AnimationPlayer.play("Normal Bullet Effect")

func _process(delta):
	if is_enemy:
		position.x -= 500 * delta
	else: position.x += move_speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
