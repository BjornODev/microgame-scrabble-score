extends RichTextLabel

@onready var anim = $"AnimationPlayer"

func intro():
	anim.stop(true)
	anim.play("come_in_and_leave")

func loser(from_ammo: bool):
	var leading_text = "[center]"
	if from_ammo:
		text = leading_text + "Out of arrows!"
	else:
		text = leading_text + "Time's up!"
	anim.stop(true)
	anim.play("come_in")

func winner():
	text = "[center]Victory!"
	anim.stop(true)
	anim.play("come_in")
