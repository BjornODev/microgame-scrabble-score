extends Node3D

@onready var game = get_parent().get_parent().get_parent()
@onready var anim = $"AnimationPlayer"

func land() -> void:
	game.chest_landed()

func open_up() -> void:
	anim.play("open")
