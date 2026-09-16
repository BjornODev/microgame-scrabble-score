extends RigidBody2D

var letter = ""
var points = 0
var marker_id = -1

@onready var glow = $Glow
@onready var sprite = $Sprite
@onready var glyph = $Glyph


func setup(texture, new_letter, new_points):
	letter = new_letter
	points = new_points
	sprite.texture = texture
	glow.visible = false
	glyph.text = ""


# Marks this as one of the tiles the player actually has to place.
func make_live(id, color, symbol):
	marker_id = id
	glow.modulate = color
	glow.visible = true
	glyph.text = symbol
	glyph.modulate = color
	start_pulse()


fun
