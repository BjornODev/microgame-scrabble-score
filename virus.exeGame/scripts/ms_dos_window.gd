extends Area2D

func _ready() -> void:
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			queue_free()
			# Subtracts one from open terminals count
			Globals.current_terminal_count -= 1
			# Adds one to total terminals closed
			Globals.terminals_closed += 1
