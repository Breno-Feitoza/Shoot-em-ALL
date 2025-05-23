extends Area2D





func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Player"):
		$AnimatedSprite2D.play("Collected")
		$CollisionShape2D.queue_free()
		area.get_parent().use_power_up()
		
		await get_tree().create_timer(1).timeout
		queue_free()
	
	pass # Replace with function body.
