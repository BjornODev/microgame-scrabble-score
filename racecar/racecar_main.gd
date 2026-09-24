class_name RacecarMain
extends MicroGame

@export var level_scenes: Array[PackedScene] = []
@export var fade_duration: float = 0.8

@onready var current_level: Node = $CurrentLevel
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

var _level_index := -1


func _ready() -> void:
	fade_rect.color.a = 0.0
	_advance_to_next_level()


func _advance_to_next_level() -> void:
	_level_index += 1

	if _level_index >= level_scenes.size():
		GameManager.win()
		return

	_load_level(_level_index)


func _load_level(index: int) -> void:
	_clear_current_level()

	var level: Node2D = level_scenes[index].instantiate()
	current_level.add_child(level)
	level.level_completed.connect(_on_level_completed)
	level.level_failed.connect(_on_level_failed)

	await _fade_in()


func _on_level_completed() -> void:
	_advance_to_next_level()


func _on_level_failed() -> void:
	GameManager.lose()
	_load_level(_level_index)


func _clear_current_level() -> void:
	for child in current_level.get_children():
		child.queue_free()


func _fade_in() -> void:
	fade_rect.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished
