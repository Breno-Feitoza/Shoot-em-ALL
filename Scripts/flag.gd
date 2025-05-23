extends Area2D

@export var scene = ""

@onready var scene_loader = get_node("/root/SceneLoader")


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		await get_tree().create_timer(0.3).timeout
		scene_loader.change_scene_with_loading(scene)
	pass # Replace with function body.
