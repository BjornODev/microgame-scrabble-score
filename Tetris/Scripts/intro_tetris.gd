extends MicroGame
const TETRIS_GAME = preload("uid://db7e73mnnwnl")
@onready var timer: Timer = $Timer





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_packed(TETRIS_GAME)
	pass
