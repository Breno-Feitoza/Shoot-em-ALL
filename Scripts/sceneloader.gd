extends Node

var loading_screen_scene = preload("res://loading_screen.tscn")

func change_scene_with_loading(scene_path: String) -> void:
	var loading_screen = loading_screen_scene.instantiate()
	get_tree().get_root().add_child(loading_screen)
	loading_screen.start_loading(scene_path)
