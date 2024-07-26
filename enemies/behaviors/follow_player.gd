extends Node

@export var speed = 1.0

var enemy: Enemy
var sprite: AnimatedSprite2D



func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D") 
	enemy.health
	pass
func _physics_process(delta: float) ->void:
	
	#ignorar game over
	if GameManager.is_game_over: return
	
	#calcula direção
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	var input_vector = difference.normalized()
	
	#movimento
	enemy.velocity = input_vector * speed * 100.0
	#
	#
	# input vector
	#velocity = input vector * speed *100.0
	enemy.move_and_slide()
	
	#girar sprite
	
	if input_vector.x >0:
		#desmarcar flip h do sprite2d
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar flip h do sprite2d
		sprite.flip_h = true
