extends AnimatedSprite2D

@onready var explosion = %Explosion


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_explosion() -> void:
	explosion.play("explode")
	await explosion.animation_finished
	self.queue_free()
