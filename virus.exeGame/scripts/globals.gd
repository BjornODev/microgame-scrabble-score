extends Node2D

var current_terminal_count : int = 0
var terminals_closed : int = 0

func reset_game() -> void:
	current_terminal_count = 0
	terminals_closed = 0
