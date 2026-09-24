extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_body_entered(_body):
	GameManager.lose()
	pass # Replace with function body.
