extends Sprite2D

@onready var anim = $"AnimationPlayer"
#@onready var other_anim = $"OtherAnimationPlayer"

#func ready_up() -> void:
	#pass
	#other_anim.play("move_up")

func reset() -> void:
	anim.stop(true)
	anim.play("restock")

func nock() -> void:
	anim.stop(true)
	anim.play("nock")

func fade_out() -> void:
	anim.stop(true)
	anim.play("fade_to_black")
	#other_anim.stop(true)
	#other_anim.play("move_down")
