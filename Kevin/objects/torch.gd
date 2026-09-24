extends Node3D

@onready var light = $"OmniLight3D"
@onready var anim = $"AnimationPlayer"

func _ready() -> void:
	anim.play("flicker")
	anim.seek(randf_range(0, 0.6))

func win() -> void:
	light.light_color = Color(0, 1, 0)

func lose() -> void:
	light.light_color = Color(1, 0, 0)
