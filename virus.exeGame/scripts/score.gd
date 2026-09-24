extends Node2D

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Lose condition
	if Globals.current_terminal_count >= 3:
		# Resets scores
		Globals.reset_game()
		
		GameManager.lose()
		game_over.emit()
		
	# Win condition
	if Globals.terminals_closed >= 15:
		# Resets scores
		Globals.reset_game()
		
		GameManager.win()
		game_over.emit()
