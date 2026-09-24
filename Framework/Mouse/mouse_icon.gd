class_name PawMouseIcon extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	make_visible()
	animation_player.play("Shmove")
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		self.global_position = get_global_mouse_position()
		


func make_visible() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	show()


func make_invisible() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hide()
