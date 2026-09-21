extends CanvasLayer

@export var game_scene: PackedScene

func _init() -> void:
	SceneTransition.fade_in()

func _on_button_button_down() -> void:
	print("fade out")
	SceneTransition.fade_out()
	await SceneTransition.animation_finished
	get_tree().change_scene_to_packed(game_scene)
