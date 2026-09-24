extends RichTextLabel

@onready var anim = $"AnimationPlayer"

func perfect():
	text = "[center]Perfect shot!"
	anim.stop(true)
	anim.play("come_in")

func you_are_stupid():
	text = "[center]Click and hold!"
	anim.stop(true)
	anim.play("come_in_long")
