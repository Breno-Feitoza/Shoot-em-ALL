extends CharacterBody2D

@export var speed = 100.0
@export var jump_force = -300.0
@export var gravity = 600.0
@export var jump_height_threshold = 20.0
@export var max_health = 150

var health: int = max_health
var is_alive = true

var target_player: Node2D = null
var detected_players: Array[Node2D] = []

func _ready():
	add_to_group("enemies")
	
func _physics_process(delta: float) -> void:
	if !is_alive:
		return

	apply_gravity(delta)
	select_target()
	if target_player != null:
		walk_to_target()
		try_jump()

	move()
	animate()
	pass

func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta
	pass

func select_target() -> void:
	if detected_players.size() == 0:
		target_player = null
		return
	pass

	var closest_dist = INF
	var closest = null
	for p in detected_players:
		var d = global_position.distance_to(p.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = p
	target_player = closest
	pass

func walk_to_target() -> void:
	var dir_x = sign(target_player.global_position.x - global_position.x)
	velocity.x = dir_x * speed
	pass

func try_jump() -> void:
	var vertical_diff = global_position.y - target_player.global_position.y
	if vertical_diff > jump_height_threshold and is_on_floor():
		velocity.y = jump_force
	pass

func move() -> void:
	self.velocity = velocity
	move_and_slide()
	velocity = self.velocity
	pass

func animate() -> void:
	if velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("Walk")
	elif is_on_floor():
		$AnimatedSprite2D.play("Idle")

	if target_player:
		if target_player.global_position.x >= global_position.x:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.position.x = 11
		else:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.position.x = -11
	pass

func take_damage(amount: int) -> void:
	if is_alive:
		health -= amount
	if health <= 0:
		die()
	pass

func die() -> void:
	is_alive = false
	$AnimatedSprite2D.play("Death")
	Global.score += 100
	$Area2D.queue_free()
	$CollisionShape2D.queue_free()
	await get_tree().create_timer(1).timeout
	queue_free()
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().die()
	pass


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		detected_players.append(area)
	pass # Replace with function body.


func _on_detection_area_area_exited(area: Area2D) -> void:
	detected_players.erase(area)
	pass # Replace with function body.
