extends CharacterBody2D

@export var gravity = 1500
@export var max_health = 500
@export var shoot_rate = 1
@export var shooting_duration = 5.0
@export var idle_duration = 5.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer

enum State {Idle, Attack}
var current_state: State
var is_alive = true
var health: int = max_health
var bullet_scene = preload("res://PreFabs/bullet(2).tscn")

var shooting_time_passed = 0.0
var idle_time_passed = 0.0
var shooting_active = true

func _ready():
	add_to_group("enemies")
	current_state = State.Idle
	shoot_timer.wait_time = shoot_rate
	shoot_timer.start()
	shooting_time_passed = 0.0
	idle_time_passed = 0.0
	shooting_active = true
	pass

func _physics_process(delta: float):
	if is_alive:
		enemy_gravity(delta)

		if shooting_active:
			shooting_time_passed += delta
			current_state = State.Attack
			if shooting_time_passed >= shooting_duration:
				shooting_active = false
				shooting_time_passed = 0.0
				idle_time_passed = 0.0
				current_state = State.Idle
		else:
			idle_time_passed += delta
			current_state = State.Idle
			if idle_time_passed >= idle_duration:
				shooting_active = true
				idle_time_passed = 0.0
				shooting_time_passed = 0.0
		
		move_and_slide()
		animations()
	
	pass

func enemy_gravity(delta: float):
	velocity.y += gravity * delta
	pass

func animations():
	if current_state == State.Idle && is_alive:
		animated_sprite_2d.play("Idle")
	elif current_state == State.Attack && is_alive:
		animated_sprite_2d.play("Attack")
	pass

func take_damage(amount: int):
	if is_alive:
		health -= amount
	if health <= 0:
		die()
	pass

func _on_shoot_timer_timeout() -> void:
	if shooting_active and is_alive:
		shooting()

func shooting() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return

	var closest_player = null
	var closest_distance = INF
	for p in players:
		var distance = position.distance_to(p.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player = p

	if closest_player == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.position = position

	var direction_to_player = (closest_player.global_position - global_position).normalized()
	bullet.direction = direction_to_player

	if closest_player.global_position.x > global_position.x:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.position.x = 10
	else:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.position.x = -10

	get_tree().current_scene.add_child(bullet)

func die():
	if is_alive:
		is_alive = false
		Global.score += 500
		$AnimatedSprite2D.play("Die")
		$Area2D.queue_free()
		await get_tree().create_timer(1).timeout
		queue_free()
	pass
