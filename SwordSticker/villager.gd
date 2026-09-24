extends Area2D

var speed : int = 110
var angle : float = 0
var first_time : bool = true
var jump : float = 0

var count : float = 0
var jiggle_mult : int = 4 + randi_range(-1,20)
@onready var left_arm: Sprite2D = $Sprite2D/LeftArm
@onready var right_arm: Sprite2D = $Sprite2D/RightArm

func _ready() -> void:
	speed += randi_range(-10,25)

func _process(delta: float) -> void:
	if position == Vector2.ZERO:
		return
	elif first_time:
		angle = get_position().angle_to(Vector2.RIGHT)
		first_time = false
	else:
		angle += delta * speed / 100
		set_position(polar_to_cartesian(angle,415-72))
	
	rotation = -get_position().angle_to(Vector2.RIGHT)
	
	right_arm.rotation = deg_to_rad(cos(count) * 10)
	left_arm.rotation = deg_to_rad(sin(count) * 10)
	skew = deg_to_rad(cos(count) * cos(count) * 10)
	count += delta * jiggle_mult

func polar_to_cartesian(radians : float, dist : float):
	return Vector2(dist * cos(radians),dist * sin(radians))


func _on_area_entered(_area: Area2D) -> void:
	speed *= -1

func _on_body_entered(_body: Node2D) -> void:
	get_parent().villager_died()
	queue_free()
