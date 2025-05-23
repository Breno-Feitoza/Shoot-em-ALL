extends StaticBody2D


var life = 1



func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Player"):
		$AnimatedSprite2D.play("Hit")
		life -= 1
		if life <= 0:
			$Area2D.queue_free()
			$CollisionShape2D.queue_free()
			
			
	
	pass # Replace with function body.
