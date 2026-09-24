extends MicroGame

const TIME = 15

## When true, resets game and plays at random difficulty.
const DEBUG = false

var shot_a_good_arrow = false

@onready var player: Node3D = $"Node3D/Player"
@onready var moving_floor: Node3D = $"Node3D/Moving Floor"
@onready var anim: AnimationPlayer = $"Node3D/AnimationPlayer"
@onready var floor_anim: AnimationPlayer = $"Node3D/Moving Floor/AnimationPlayer"

@onready var arrow_ui = $"CanvasLayer/Control/Bottom Right/Arrow UI Center"
@onready var clock_timer = $"CanvasLayer/Control/Bottom Left/Clock Timer"
@onready var why_you_lost = $"CanvasLayer/Control/CenterContainer/Why You Lost"
@onready var perfect_arrow_text = $"CanvasLayer/Control/Bottom Middle/Perfect Arrow"

@onready var scope: TextureProgressBar = $"CanvasLayer/Control/CenterContainer/ScopeBar"

@onready var node3d: Node3D = $"Node3D"
@onready var shadow: OmniLight3D = $"Node3D/Shadow"

@onready var quick_loss_timer: Timer = $"Quick Loss Timer"
@onready var win_or_lose_timer: Timer = $"Win or Lose Timer"

@onready var music = $"Music"

var win_music = preload("res://Kevin/assets/sounds/Quiver_Win.wav")
var lose_music = preload("res://Kevin/assets/sounds/Quiver_Lose.wav")

var target = preload("res://Kevin/objects/target.tscn")
var targets_left: int = 0
const MAX_AMMO: int = 6

@onready var torches = [
	$"Node3D/Wall Left/Torch", $"Node3D/Wall Left/Torch2", $"Node3D/Wall Left/Torch3",
	$"Node3D/Wall Right/Torch4", $"Node3D/Wall Right/Torch5", $"Node3D/Wall Right/Torch6"
	]

var arrows_left_to_land: int

var game_over = false
var won = false

func _ready() -> void:
	if DEBUG:
		difficulty = randf_range(0, 1)
	GameManager.get_node("Background").hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	targets_left = 3
	# starting position of targets. Helps produce y placement variety.
	var rand_y_origin = randi_range(2, 4)
	# Number of moving targets. Determined by difficulty with no RNG.
	var moving_target_count = min(3, int(difficulty * 4))
	# All new targets are added here so I can MOVE them around.
	var all_targets = []
	for i in targets_left:
		var new_target = target.instantiate()
		node3d.add_child(new_target)
		new_target.ready_by_parent(Vector3(28, rand_y_origin + (i * 3), randi_range(-6, 6)))
		all_targets.append(new_target)
	# Picks random targets to start moving.
	for i in moving_target_count:
		if all_targets.size() > 0:
			all_targets.pop_at(randi_range(0, all_targets.size() - 1)).start_moving(randf_range(3, 3.5 + difficulty * 6))
		else:
			break
	arrows_left_to_land = MAX_AMMO
	moving_floor.position.x = 26 - (difficulty * 32)
	player.ready_by_parent(MAX_AMMO, Vector3(16 - (difficulty * 32), 4, 0), scope)
	arrow_ui.ready_by_parent(MAX_AMMO)

## When the player reaches their goal position. Starts timers and all that.
func officially_start():
	floor_anim.play("start")
	await floor_anim.animation_finished
	clock_timer.reset_time(TIME)
	why_you_lost.intro()
	player.start_playing()

func nock_arrow() -> void:
	arrow_ui.nock_arrow()

func shoot_arrow(charge: float) -> void:
	if charge <= 0.2 and !shot_a_good_arrow:
		perfect_arrow_text.you_are_stupid()
	else:
		shot_a_good_arrow = true
	arrow_ui.shoot_arrow()

func target_hit() -> void:
	targets_left -= 1
	if targets_left == 0:
		win()

func secret_hit() -> void:
	shadow.light_negative = false
	arrows_left_to_land += player.restock()
	arrow_ui.restock()

## Adds two arrows left to land to prevent game from making you lose early from running out of arrows.
func perfect_arrow_shot() -> void:
	arrows_left_to_land += 2
	perfect_arrow_text.perfect()

func arrow_landed() -> void:
	arrows_left_to_land -= 1
	if arrows_left_to_land == 0:
		quick_loss_timer.start()

func win():
	if !game_over:
		won = true
		game_over = true
		for torch in torches:
			torch.win()
		clock_timer.stop_running()
		win_or_lose_timer.wait_time = 3.5
		win_or_lose_timer.start()
		why_you_lost.winner()
		floor_anim.play("win")
		music.stop()
		music.stream = win_music
		music.play()

func lose(from_ammo: bool):
	if !game_over:
		game_over = true
		for torch in torches:
			torch.lose()
		clock_timer.stop_running()
		win_or_lose_timer.wait_time = 2.5
		win_or_lose_timer.start()
		why_you_lost.loser(from_ammo)
		anim.play("lose")
		music.stop()
		music.stream = lose_music
		music.play()

func end_and_exit():
	GameManager.get_node("Background").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if won:
		GameManager.win()
	else:
		GameManager.lose()


## If ammo runs out and the last arrow clearly hasn't hit anything important.
func _on_quick_loss_timer_timeout() -> void:
	if !arrows_left_to_land:
		lose(true)

func chest_landed() -> void:
	player.chest_landed()

func _on_win_or_lose_timer_timeout() -> void:
	if DEBUG:
		get_tree().reload_current_scene()
	else:
		end_and_exit()

func play_music() -> void:
	music.play()
