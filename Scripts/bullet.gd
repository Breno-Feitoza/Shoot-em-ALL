extends Area2D

@export var speed = 400
var direction = Vector2(0,0)
@export var damage_amount: int = 50

func _physics_process(delta):
	position += speed * direction * delta
	
	pass

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group("enemies"):
		var enemy = body.get_node_or_null("./")
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage_amount)
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()

func get_damage_amount() -> int:
	return damage_amount
	pass
