extends CharacterBody2D

@export var patrol_points : Node
@export var speed = 4000
@export var max_health = 50

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var shoot_timer = $ShootTimer



enum State {Idle, Walk}
var current_state: State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool
var is_alive = true
var health: int = max_health
var bullet_scene = preload("res://PreFabs/bullet(2).tscn")

func _ready():
	add_to_group("enemies")
	if patrol_points != null:
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		number_of_points = point_positions.size()
		current_point_position = 0
		current_point = point_positions[current_point_position]
	else: 
		print("no patrol points")

	current_state = State.Idle
	can_walk = true
	pass

func _physics_process(delta: float):
	if is_alive:
		enemy_idle(delta)
		enemy_walk(delta)
		
		move_and_slide()
		animations()
	
	pass

func enemy_idle(delta: float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle
		if shoot_timer.is_stopped():
			shoot_timer.start()
			await get_tree().create_timer(3).timeout
			shoot_timer.stop()
	
	pass

func enemy_walk(delta: float):
	if !can_walk:
		return

	if abs(position.x - current_point.x) > 1:
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		velocity.x = 0
		can_walk = false
		timer.start()

		current_point_position = (current_point_position + 1) % number_of_points
		current_point = point_positions[current_point_position]

	if direction.x > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.position.x = 10
	else:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.position.x = -10

	pass

func animations():
	if current_state == State.Idle && !can_walk && is_alive:
		animated_sprite_2d.play("Idle")
	elif current_state == State.Walk && can_walk && is_alive:
		animated_sprite_2d.play("Walk")
	pass

func take_damage(amount: int):
	if is_alive:
		health -= amount
	if health <= 0:
		die()
	pass

func shooting() -> void:
	if !is_alive:
		return

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
		animated_sprite_2d.position.x = 9
	else:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.position.x = -9

	get_tree().current_scene.add_child(bullet)

	pass

func die():
	if is_alive:
		is_alive = false
		$AnimatedSprite2D.play("Die")
		$Area2D.queue_free()
		Global.score += 50
		await get_tree().create_timer(1).timeout
		queue_free()
	pass

func _on_timer_timeout() -> void:
	if is_alive:
		can_walk = true
	pass


func _on_shoot_timer_timeout() -> void:
	shooting()
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().die()
	pass # Replace with function body.
