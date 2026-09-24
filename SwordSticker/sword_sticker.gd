extends MicroGame

@onready var sfx_sword_slam: AudioStreamPlayer = $SfxSwordSlam

const STICKER = preload("res://SwordSticker/sticker.tscn")
@onready var stick_point: Vector2 = $StickPoint.get_global_position()
@onready var counter_label: Label = $LoseTimer/CounterLabel
@onready var lose_timer: Timer = $LoseTimer

var projectile: Sprite2D
@onready var proj_point: Vector2 = $ProjPoint.get_global_position()

@onready var spin_world: Sprite2D = $SpinWorld
var speed : float = 1
@export var proj_speed : int = 1000
var proj_moving : bool = false

@onready var sfx_ticking: AudioStreamPlayer = $SfxTicking
@onready var extra_time_label: Label = $LoseTimer/ExtraTimeLabel

@onready var start_timer: Timer = $InstructionMenu/StartTimer
@onready var instruction_menu: Control = $InstructionMenu
@onready var animation_player: AnimationPlayer = $LoseTimer/CounterLabel/AnimationPlayer

@onready var center: Node2D = $Center
const ENEMY = preload("res://SwordSticker/enemy.tscn")
const VILLAGER = preload("res://SwordSticker/villager.tscn")

var count : int = 10

func _ready() -> void:
	create_projectile()
	speed *= exp(difficulty)
	create_enemies(int(difficulty * 5 + 4))
	create_villagers(int(difficulty * 6 + 3))
	


@onready var winscreen: Control = $Winscreen
@onready var win_player: AnimationPlayer = $Winscreen/WinPlayer
@onready var sfx_ogre_dies: AudioStreamPlayer = $Center/SfxOgreDies

func win():
	if losescreen.visible == true:
		return
	
	counter_label.visible = false
	extra_time_label.visible = false
	start_timer.start(100)
	projectile.visible = false
	
	
	winscreen.visible = true
	win_player.play("SwordStab")
	win_player.connect("animation_finished",player_won)
	sfx_ogre_dies.play()
	
	
	
func player_won(_null = null):
	GameManager.win()

@onready var losescreen: Control = $Losescreen
@onready var lose_player: AnimationPlayer = $Losescreen/LosePlayer
@onready var sfx_villager_dies: AudioStreamPlayer = $Center/SfxVillagerDies

func lose():
	if winscreen.visible == true:
		return
	
	counter_label.visible = false
	extra_time_label.visible = false
	start_timer.start(100)
	projectile.visible = false
	
	losescreen.visible = true
	lose_player.play("SwordStab")
	lose_player.connect("animation_finished",player_lost)
	sfx_villager_dies.play()

func player_lost(_null = null):
	GameManager.lose()

func _process(delta: float) -> void:
	spin_world.rotate(speed * delta)
	
	if not start_timer.is_stopped():
		return
	
	if proj_moving:
		projectile.set_position(
			projectile.get_position().move_toward(
				stick_point,proj_speed*delta))
		if projectile.get_position() == stick_point:
			create_spinner_sticker()
			projectile.queue_free()
			proj_moving = false
			
			create_projectile()
			
			
	elif Input.is_action_just_pressed("space") and projectile:
		proj_moving = true
		

func create_spinner_sticker():
	var sticker = STICKER.instantiate()
	sticker.get_child(0).queue_free()
	spin_world.add_child(sticker)
	sticker.set_global_position(stick_point)
	sticker.rotation -= spin_world.rotation
	sfx_sword_slam.play(1.15)

func create_projectile():
	var sticker = STICKER.instantiate()
	add_child(sticker)
	sticker.set_global_position(proj_point)
	projectile = sticker

func create_enemies(num : int):
	for _i in range(0,num):
		var enemy = ENEMY.instantiate()
		center.add_child(enemy)
		enemy.rotate(spin_world.rotation)
		var rads = deg_to_rad(randi_range(1,360))
		var dist = spin_world.get_global_position().distance_to(stick_point)
		enemy.set_position(polar_to_cartesian(rads,dist))
		
func create_villagers(num : int):
	for _i in range(0,num):
		var villager = VILLAGER.instantiate()
		center.add_child(villager)
		villager.rotate(spin_world.rotation)
		var rads = deg_to_rad(randf_range(1,360))
		var dist = spin_world.get_global_position().distance_to(stick_point)
		villager.set_position(polar_to_cartesian(rads,dist))
	
func polar_to_cartesian(radians : float, dist : float):
	return Vector2(dist * cos(radians),dist * sin(radians))
	

func _on_lose_timer_timeout() -> void:
	sfx_ticking.play()
	
	animation_player.play("CounterScale")
	
	count -= 1
	counter_label.text = str(count)
	if count <= 0:
		lose()
		lose_timer.stop()

func increase_count() -> void:
	extra_time_label.add_text("\nBONUS! +1")
	count += 1
	counter_label.text = str(count)

func decrease_count() -> void:
	extra_time_label.add_text("\nPENALTY! -1")
	count -= 1
	counter_label.text = str(count)


func _on_start_timer_timeout() -> void:
	lose_timer.start()
	center.visible = true
	instruction_menu.visible = false
