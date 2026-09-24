extends Control

signal intro_finished

func _on_video_stream_player_finished() -> void:
	intro_finished.emit()
	queue_free()
