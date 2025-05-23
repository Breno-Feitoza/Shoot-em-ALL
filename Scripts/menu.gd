extends Control

@onready var scene_loader = get_node("/root/SceneLoader")

var buttons: Array[Button]
var focused_index := 0

func _ready():
	buttons = [$VBoxContainer/Play,$VBoxContainer/Quit]

	buttons[focused_index].grab_focus()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu_down"):
		focused_index = (focused_index + 1) % buttons.size()
		buttons[focused_index].grab_focus()

	elif Input.is_action_just_pressed("menu_UP"):
		focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
		buttons[focused_index].grab_focus()

	elif Input.is_action_just_pressed("menu_accept"):
		buttons[focused_index].pressed.emit()
	pass



func _on_play_pressed() -> void:
	scene_loader.change_scene_with_loading("res://Scenes/level_1.tscn")
	
	pass


func _on_quit_pressed() -> void:
	
	get_tree().quit()
	
	pass
