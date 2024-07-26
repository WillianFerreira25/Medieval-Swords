class_name Player
extends CharacterBody2D

@export_category("movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $swordArea
@onready var hitbox_area: Area2D = $hitboxarea
@export_category("life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

@export_category("ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene




var input_vector: Vector2 = Vector2 (0,0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var is_attacking_cooldown : float = 0.0
var hitbox_cooldown : float = 0.0
var ritual_cooldown : float = 0.0
var is_attack_up: bool = false
var is_attack_down: bool = false


signal meat_collected(value: int)
signal gold_collected(value: int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int ): 
		GameManager.meat_counter += 1)
	gold_collected.connect(func(value:int ): 
		GameManager.gold_counter += 1)

func _process(delta: float) -> void:
	
	GameManager.player_position = position
	read_input()

	#processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	update_attack_cooldown(delta)
	# processar dano
	update_hitbox_detection(delta)
	#ritual
	update_ritual(delta)
	
	#atualizar heath bar
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

	if Input.is_action_just_pressed("attack"):
		attack()
		
func update_ritual(delta: float) -> void:
	#atualizador temporizador
	ritual_cooldown-= delta
	if  ritual_cooldown >0 : return
	ritual_cooldown = ritual_interval
	
	#criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
	
	

func _physics_process(delta: float) -> void:

		#modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()
	
	
	
func update_attack_cooldown(delta: float) -> void:
		
	#atualizar temporizador
	if is_attacking:
		is_attacking_cooldown -= delta
		if is_attacking_cooldown <= 0.0:
			is_attacking = false
			is_attack_up = false
			is_attack_down = false
			is_running = false
			animation_player.play("idle")
	
func read_input() -> void:
	
			#obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#apagar deadzone do inputvector
	var deadzone=0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
		# atualizar o is_runnig
	was_running = is_running
	is_running =not input_vector.is_zero_approx()
	
	
func play_run_idle_animation() -> void:
	#tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			

func rotate_sprite()-> void:
	
	#girar sprite
	
	if input_vector.x >0:
		#desmarcar flip h do sprite2d
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar flip h do sprite2d
		sprite.flip_h = true
	

func attack() -> void:
	if is_attacking:
		return
	
	if input_vector.y < 0:
		is_attack_up = true
		animation_player.play("atack_up_1")
	elif input_vector.y > 0:
		is_attack_down = true
		animation_player.play("atack_down_2")
		
	else:
		animation_player.play("atack_side_1")
	#tocar animação
	
	
	is_attacking_cooldown = 0.6
	is_attacking = true
	
	
	
	

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			
			if is_attack_up:
				attack_direction = Vector2.UP
				print("alto")
			elif is_attack_down:
				attack_direction = Vector2.DOWN
				print("baixo")
			elif sprite.flip_h:
				attack_direction = Vector2.LEFT
				print("lateral")
			else:
				attack_direction = Vector2.RIGHT
		
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.45:
				enemy.damage(sword_damage)
			
			
			
func update_hitbox_detection(delta:float) -> void:
	#temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	#frequencia 2x por segundo
	hitbox_cooldown = 0.5
	
	#detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
	pass
	
	
	
func damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	print("Player recebeu dano de ", amount, ". A vidad total é de ", health)
	
	#piscar inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween . TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#processar morte
	if health <=0:
		die()
		
		
func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	queue_free()
	
	
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("player recebeu cura de", amount, "A vida total é de ", health)
	return health


