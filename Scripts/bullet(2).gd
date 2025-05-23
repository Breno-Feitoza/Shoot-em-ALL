extends Area2D

@export var speed = 150
var direction = Vector2(0,0)

func _physics_process(delta):
	position += speed * direction * delta
	
	pass

func _on_timer_timeout() -> void:
	queue_free()
	pass



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().die()
		print("morreu")
		queue_free()
	if area.is_in_group("player_bullets"):
		queue_free()
	pass # Replace with function body.
