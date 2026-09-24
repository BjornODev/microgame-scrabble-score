extends CharacterBody3D

#@onready var light = $"OmniLight3D"
@onready var anim = $"AnimationPlayer"
## If true, reveals a little secret ;)
@export var secret = false

const Z_CLAMPS = [-6, 6]

var moving_speed: float = 0
var scored = false

func _ready() -> void:
	if secret:
		anim.play("secret")

func ready_by_parent(spawn_pos: Vector3) -> void:
	position = spawn_pos

func get_hit() -> void:
	if !scored:
		scored = true
		collision_layer = 1
		moving_speed = 0
		if secret:
			get_parent().get_parent().secret_hit()
		else:
			get_parent().get_parent().target_hit()
		anim.play("hit")
		#light.light_energy = 0
		#queue_free()

func _physics_process(delta: float) -> void:
	if moving_speed:
		position.z += moving_speed * delta
		if moving_speed > 0 and position.z > Z_CLAMPS[1]:
			position.z = Z_CLAMPS[1]
			moving_speed = -abs(moving_speed)
		elif moving_speed < 0 and position.z < Z_CLAMPS[0]:
			position.z = Z_CLAMPS[0]
			moving_speed = abs(moving_speed)

func start_moving(base_speed: float) -> void:
	moving_speed = ((randi_range(0, 1) * 2) - 1) * base_speed
