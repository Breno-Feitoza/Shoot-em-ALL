extends Control

@onready var label = $CenterContainer/VBoxContainer/Label
@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar

var next_scene_path := ""
var animation_timer := 0.0
var dots := ""
var elapsed := 0.0
var loading_duration := 3.0 

func start_loading(scene_path: String) -> void:
	next_scene_path = scene_path
	visible = true
	animation_timer = 0.0
	dots = ""
	elapsed = 0.0
	progress_bar.value = 0
	set_process(true)

	await get_tree().process_frame


	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
		get_tree().current_scene = null


	# Espera 3s com loading visível
	while elapsed < loading_duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		progress_bar.value = (elapsed / loading_duration) * 100

# Troca de cena — o Godot já remove a cena anterior automaticamente!
	get_tree().change_scene_to_file(next_scene_path)

	await get_tree().process_frame
	queue_free()


	pass

func _process(delta: float) -> void:
	animation_timer += delta
	if animation_timer >= 0.5:
		animation_timer = 0.0
		dots = dots + "."
		if dots.length() > 3:
			dots = ""
		label.text = "Carregando" + dots
	pass
