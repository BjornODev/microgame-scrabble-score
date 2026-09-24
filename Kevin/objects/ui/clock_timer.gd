extends Sprite2D

var time: int = 15

var running = false

@onready var game = get_parent().get_parent().get_parent().get_parent()
@onready var text = $"RichTextLabel"
@onready var timer = $"Timer"
@onready var anim = $"AnimationPlayer"

func reset_time(max_time: int) -> void:
	time = max_time
	update_time()
	timer.start()
	running = true

func update_time() -> void:
	if time < 0:
		game.lose(false)
		stop_running()
		text.text = "Out of time!"
	else:
		text.text = str(time)
	if time <= 5:
		anim.play("low")
	else:
		anim.play("not_low")

func stop_running() -> void:
	running = false
	timer.stop()

func _on_timer_timeout() -> void:
	if running:
		time -= 1
		update_time()
