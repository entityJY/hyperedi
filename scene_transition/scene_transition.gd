extends CanvasLayer
class_name SceneFade

@export var animation_player: AnimationPlayer

@export var music_sources: Array[AudioStreamMP3]
var curr_music_index = 0
@export var audio_stream_player: AudioStreamPlayer

signal animation_finished()


func _ready() -> void:
	_on_audio_stream_player_finished()

func fade_in() -> void:
	animation_player.play("fade_in")

func fade_out() -> void:
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_finished.emit()

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(3).timeout
	audio_stream_player.stream = music_sources[curr_music_index]
	audio_stream_player.play(0)
	curr_music_index += 1
