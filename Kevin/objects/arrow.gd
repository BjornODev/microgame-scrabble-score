extends CharacterBody3D

@onready var area = $"Area3D"
@onready var anim = $"AnimationPlayer"

var speed: float = 45 # usually
var fall_speed: float = 0 # determines gravity
#var immune_to_gravity_time: float = 0 # when 0, starts rotating downwards
var flying: bool = true

var game: Node3D

func spawn_by_parent(spawn_pos: Vector3, spawn_rotation: Vector3, charge_time: float) -> void:
	position = spawn_pos
	rotation = spawn_rotation
	game = get_parent().get_parent()
	speed = clamp(charge_time * 100, 15, 100)
	fall_speed = 50 / speed
	anim.speed_scale = (speed / 25)
	anim.play("fly")
	#immune_to_gravity_time = min(charge_time, 1)

func _physics_process(delta: float) -> void:
	if flying:
		#immune_to_gravity_time = move_toward(immune_to_gravity_time, 0, delta)
		#if !immune_to_gravity_time:
			#rotation.x = move_toward(rotation.x, -PI/2, delta)
		rotation.x = move_toward(rotation.x, -PI/2, delta * fall_speed)
		var collision = move_and_collide(-transform.basis.z * delta * speed)
		if collision != null:
			flying = false
			anim.stop(true)
			anim.speed_scale = 1
			anim.play("land")
			game.arrow_landed()
			await get_tree().process_frame
			area.set_deferred("collision_mask", 0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	body.get_hit()
