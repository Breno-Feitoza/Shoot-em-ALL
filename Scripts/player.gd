extends CharacterBody2D

var Jump = -300
var gravity = 980
var jumps = 1
var dir 
var speed = 160
var is_alive = true
var bullet_scene = preload("res://PreFabs/bullet.tscn")
@export var base_damage := 50
var damage_multiplier := 1.0

var side = "Right"


@onready var muzzle = $Muzzle
@onready var shoot_sound = $ShootSound


@export var left = "Left"
@export var right = "Right"
@export var jump = "Jump"
@export var shoot = "Shoot"
@export var look_up = "LookUp"




func _physics_process(delta: float) -> void:
	move(delta)

	if is_alive:
		animations()
		player_shooting(delta)

	
	pass


func move(delta):
	if is_alive:
		dir = Input.get_axis(left,right)
	
	if dir:
		velocity.x = dir * speed
	elif dir == 0:
		velocity.x = 0
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_alive:
		if Input.is_action_just_pressed(jump) and jumps > 0:
			velocity.y = Jump
			jumps -= 1
	
	if is_on_floor():
		jumps = 1

	move_and_slide()
	
	
	pass
	

func animations():
	
	if velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("Run")
	elif velocity.x == 0 and is_on_floor():
		$AnimatedSprite2D.play("Idle")
		

	if velocity.x == 0 and Input.is_action_pressed(look_up):
		$AnimatedSprite2D.play("Look_up")
		

	if not is_on_floor() and jumps >= 1:
		$AnimatedSprite2D.play("Jump")
		
	if dir > 0:
		side = "Right"
		$AnimatedSprite2D.flip_h = false
	elif dir < 0:
		side = "Left"
		$AnimatedSprite2D.flip_h = true
	
	pass
	
func player_shooting(delta: float) -> void:
	if Input.is_action_just_pressed(shoot) and is_alive:
		var bullet = bullet_scene.instantiate()
		bullet.position = position

		if Input.is_action_pressed(look_up) and velocity.x == 0:
			bullet.direction = Vector2(0 , -1)
		elif side == "Right":
			bullet.direction = Vector2(1 , 0)
		elif side == "Left":
			bullet.direction = Vector2(-1 , 0)

		bullet.damage_amount = base_damage
		get_tree().current_scene.add_child(bullet)
		shoot_sound.play()

pass

func die():
	if is_alive:
		is_alive = false
		Global.alive_players -= 1
		
		$AnimatedSprite2D.play("Hit")
		$CollisionShape2D.queue_free()
		$Area2D.queue_free()
		velocity.y = Jump

		if Global.alive_players == 0:
			await camera_zoom()  # Só aplica o zoom quando o último morrer
			await get_tree().create_timer(1).timeout
			get_tree().reload_current_scene()
			Global.score = 0
			Global.alive_players = 2  # Reset para a próxima cena
		
	pass

func use_power_up():
	
	base_damage *= damage_multiplier * 2.0
	
	pass

func camera_zoom():
	
	var zoom_value = 1.5
	
	$Camera2D.zoom = Vector2(zoom_value , zoom_value)
	Engine.time_scale = 0.5
	
	await get_tree().create_timer(0.8).timeout
	
	$Camera2D.zoom = Vector2(1 , 1)
	Engine.time_scale = 1
	
	
	pass
