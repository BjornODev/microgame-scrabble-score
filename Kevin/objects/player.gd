extends Node3D

@onready var camera_pivot: Node3D = $"CameraPivot"
@onready var camera: Camera3D  = $"CameraPivot/Camera3D"
@onready var game = get_parent().get_parent()
@onready var anim = $"AnimationPlayer"

const MOUSE_SENSITIVITY = 0.002
const PERFECT_ARROW_MIN_CHARGE = 1.0
const PERFECT_ARROW_MAX_CHARGE = 1.05
const PERFECT_ARROW_OFFSET_MIN = 0.025
const PERFECT_ARROW_OFFSET_MAX = 0.1

## Used for animations only.
const MOVE_SPEED = 4

var charge_time: float = 0
var ammo: int = 0

var played_music = false

## Set to true after intro cutscene finishes, which then allows for player input.
var playing = false
## For the player's entrance animation.
var moving = false

var starting_pos: Vector3

var scope: TextureProgressBar

var arrow = preload("res://Kevin/objects/arrow.tscn")

# let's a play
func _ready() -> void:
	camera.set_current(true)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var camera_movement: Vector2
		camera_movement = event.screen_relative * -MOUSE_SENSITIVITY
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + camera_movement.y, -PI / 2, PI / 2)
		camera_pivot.rotate_y(camera_movement.x)

func _physics_process(delta: float) -> void:
	if playing:
		if !Input.is_action_pressed("kevin_quiver_game_arrow") and ammo and charge_time:#charge_time >= CHARGE_MIN) and ammo:
			if charge_time >= PERFECT_ARROW_MIN_CHARGE and charge_time <= PERFECT_ARROW_MAX_CHARGE:
				# higher difficulties decrease perfect arrow offset to ensure they're viable at all distances
				var perfect_arrow_offset = PERFECT_ARROW_OFFSET_MIN + ((1 - game.difficulty) * (PERFECT_ARROW_OFFSET_MAX - PERFECT_ARROW_OFFSET_MIN))
				summon_arrow(camera_pivot.global_rotation + Vector3(perfect_arrow_offset, 0, 0), charge_time, false)
				summon_arrow(camera_pivot.global_rotation - Vector3(perfect_arrow_offset, 0, 0), charge_time, false)
				game.perfect_arrow_shot()
			summon_arrow(camera_pivot.global_rotation, charge_time, true)
			ammo -= 1
			charge_time = 0
		if ammo and (Input.is_action_pressed("kevin_quiver_game_arrow") or charge_time):
			if !charge_time:
				game.nock_arrow()
			charge_time += delta
		scope.value = charge_time * 100
	elif moving:
		if !played_music:
			played_music = true
			game.play_music()
		position.x = move_toward(position.x, starting_pos.x, MOVE_SPEED * delta)
		if abs(position.x - starting_pos.x) < 0.1:
			moving = false
			game.officially_start()
	#if Input.is_action_just_pressed("ctrl"):
		#get_tree().quit()

func summon_arrow(arrow_rot: Vector3, charge: float, eat_arrow: bool) -> void:
	var new_arrow = arrow.instantiate()
	add_sibling(new_arrow)
	new_arrow.spawn_by_parent(camera_pivot.global_position, arrow_rot, charge)
	if eat_arrow:
		game.shoot_arrow(charge)

func ready_by_parent(new_ammo: int, spawn_pos: Vector3, new_scope: TextureProgressBar):
	ammo = new_ammo
	starting_pos = spawn_pos
	position = Vector3(spawn_pos.x - MOVE_SPEED / 2.0, spawn_pos.y, spawn_pos.z)
	scope = new_scope
	moving = true

func start_playing() -> void:
	playing = true

func _on_culling_area_body_exited(body: Node3D) -> void:
	body.show()

## Returns number of arrows restocked.
func restock() -> int:
	var result = 1 #var result = MAX_AMMO - ammo
	ammo += 1
	return result

func chest_landed() -> void:
	anim.stop(true)
	anim.play("shake")

func wall_shake() -> void:
	anim.stop(true)
	anim.play("wall_shake_infinite")
	
