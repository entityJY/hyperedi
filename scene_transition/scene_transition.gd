extends CanvasLayer
class_name SceneFade

@export var animation_player: AnimationPlayer

signal animation_finished()

func fade_in() -> void:
	animation_player.play("fade_in")

func fade_out() -> void:
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit()
