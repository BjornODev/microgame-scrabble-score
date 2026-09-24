class_name VirusGame extends MicroGame

const CURSOR = preload("res://virus.exeGame/Assets/sprites/cursor.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.reset_game()
	Input.set_custom_mouse_cursor(CURSOR)

func _on_score_game_over() -> void:
	get_tree().call_group("terminals", "queue_free")
