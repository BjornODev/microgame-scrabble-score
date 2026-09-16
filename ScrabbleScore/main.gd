extends MicroGame

const TILE_SCENE = preload("res://ScrabbleScore/Scenes/Tile.tscn")
const TARGET_SCENE = preload("res://ScrabbleScore/Scenes/Target.tscn")
const BoardData = preload("res://ScrabbleScore/Data/board_data.gd")

const LETTER_PATH = "res://ScrabbleScore/Assets/Blue/letter_%s.png"
const BLANK_PATH = "res://ScrabbleScore/Assets/Blue/letter.png"

const GRID = 15
const BAG = "AEIORTLSNUDGBCMPFHVWY"

const BOARD_TEXTURE_SIZE = 1260.0
const PLAYFIELD_INSET = 60.0
const SOURCE_CELL = 76.0

# . plain   d double letter   t triple letter   D double word   T triple word
const PREMIUM = [
	"T......T......T",
	".D.d..t.t..d.D.",
	"..D..d...d..D..",
	".d.D.......D.d.",
	"....D..d..D....",
	"..d..t...t..d..",
	".t....d.d....t.",
	"T...d..T..d...T",
	".t....d.d....t.",
	"..d..t...t..d..",
	"....D..d..D....",
	".d.D.......D.d.",
	"..D..d...d..D..",
	".D.d..t.t..d.D.",
	"T......T......T",
]

const POINTS = {
	"A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, "G": 2, "H": 4, "I": 1,
	"J": 8, "K": 5, "L": 1, "M": 3, "N": 1, "O": 1, "P": 3, "Q": 10, "R": 1,
	"S": 1, "T": 1, "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4, "Z": 10,
}

const COLORS = [Color("ff8c1a"), Color("a3ff3c"), Color("c46bff"), Color("ff4d4dff")]
const GLYPHS = ["j", "f", "h", "q"]

@export var cell_size: float = 36.0
@export var hand_size: int = 7
@export var follow_speed: float = 14.0
@export var seconds_per_tile_easy: float = 2.0
@export var seconds_per_tile_hard: float = 1.1
@export var reaction_bonus: float = 0.8
@export var wrong_click_penalty: float = 0.12

@onready var world: Node2D = $World
@onready var board_art: Sprite2D = $World/BoardArt
@onready var board: Node2D = $World/Board
@onready var targets: Node2D = $World/Targets
@onready var hand: Node2D = $World/Hand

@onready var pick_up_tween = $Juice/PickUp
@onready var snap_tween = $Juice/Snap
@onready var squash = $Juice/Squash
@onready var nudge = $Juice/Nudge

@onready var timer_bar = $TimerBar

var board_origin = Vector2.ZERO
var board_rows = []
var play = {}
var live_count = 0
var live_tiles = []
var marker_order = []
var all_tiles = []
var carried = null
var started = false
var finished = false
var time_left = 0.0
var start_time = 0.0
var score = 0


func _ready():
	# Difficulty decides how many tiles the play needs, then the board offers a
	# pre-verified legal play of that size.
	var wanted = int(clamp(2 + round(difficulty * 2), 1, 4))
	var board_data = BoardData.BOARDS[randi() % BoardData.BOARDS.size()]
	board_rows = board_data["rows"]
	play = pick_play(board_data["plays"], wanted)
	live_count = play["cells"].size()

	# Which colour and glyph each cell gets, decoupled from reading order.
	var palette = range(COLORS.size())
	palette.shuffle()
	marker_order = palette.slice(0, live_count)

	var screen = get_viewport().get_visible_rect().size
	var board_scale = cell_size / SOURCE_CELL

	board_art.centered = false
	board_art.scale = Vector2(board_scale, board_scale)
	board_art.position = Vector2((screen.x - BOARD_TEXTURE_SIZE * board_scale) / 2.0, 6.0)

	board_origin = board_art.position + Vector2(PLAYFIELD_INSET, PLAYFIELD_INSET) * board_scale

	# Budget time per tile so extra tiles do not stack on top of a shrinking clock.
	var per_tile = lerp(seconds_per_tile_easy, seconds_per_tile_hard, difficulty)
	time_left = per_tile * live_count + reaction_bonus
	start_time = time_left

	build_board()
	deal_hand()
	make_targets()


func _process(delta):
	# _process does not run until the framework unpauses the tree, so this is
	# where the round actually begins.
	if not started:
		started = true
		next_tile()
		return

	if not finished:
		time_left -= delta
		timer_bar.set_progress(time_left / start_time)
		if time_left <= 0.0:
			round_lost()
			return

	if carried != null:
		var mouse = world.get_global_mouse_position()
		carried.global_position = carried.global_position.lerp(mouse, follow_speed * delta)


func pick_play(plays, wanted):
	var matches = []
	for p in plays:
		if p["cells"].size() == wanted:
			matches.append(p)
	if matches.size() > 0:
		return matches[randi() % matches.size()]

	# No play of that size on this board, take the closest one.
	var best = plays[0]
	for p in plays:
		if abs(p["cells"].size() - wanted) < abs(best["cells"].size() - wanted):
			best = p
	return best


func cell_position(x, y):
	return board_origin + Vector2(x, y) * cell_size + Vector2(cell_size, cell_size) / 2.0


func letter_texture(letter):
	return load(LETTER_PATH % letter)


func build_board():
	for y in range(GRID):
		for x in range(GRID):
			var letter = board_rows[y][x]
			if letter == ".":
				continue
			var tile = TILE_SCENE.instantiate()
			board.add_child(tile)
			tile.setup(letter_texture(letter), letter, POINTS[letter], cell_size)
			tile.position = cell_position(x, y)
			all_tiles.append(tile)


func deal_hand():
	var screen = get_viewport().get_visible_rect().size
	var spacing = cell_size * 1.3
	var start_x = screen.x / 2.0 - (hand_size - 1) * spacing / 2.0
	var hand_y = screen.y - cell_size * 1.1

	# Which slots hold the real tiles. The rest are decoration.
	var slots = range(hand_size)
	slots.shuffle()
	var live_slots = slots.slice(0, live_count)

	var letters = []
	for i in range(hand_size):
		letters.append(BAG[randi() % BAG.length()])
	for i in range(live_count):
		letters[live_slots[i]] = play["letters"][i]

	var dealt = []
	for i in range(hand_size):
		var tile = TILE_SCENE.instantiate()
		hand.add_child(tile)
		tile.setup(letter_texture(letters[i]), letters[i], POINTS[letters[i]], cell_size)
		tile.position = Vector2(start_x + i * spacing, hand_y)
		dealt.append(tile)
		all_tiles.append(tile)

	# Marker i has to pair with play cell i, so this order matters.
	for i in range(live_count):
		var m = marker_order[i]
		var tile = dealt[live_slots[i]]
		tile.make_live(m, COLORS[m], GLYPHS[m])
		live_tiles.append(tile)

	# The order tiles arrive in is separate from which marker they carry.
	live_tiles.shuffle()


func make_targets():
	var blank = load(BLANK_PATH)
	for i in range(play["cells"].size()):
		var m = marker_order[i]
		var cell = play["cells"][i]
		var target = TARGET_SCENE.instantiate()
		targets.add_child(target)
		target.setup(blank, m, COLORS[m], GLYPHS[m], cell_size)
		target.position = cell_position(cell.x, cell.y)
		target.clicked.connect(on_target_clicked)


func next_tile():
	if live_tiles.size() == 0:
		round_won()
		return
	carried = live_tiles.pop_front()
	carried.z_index = 100
	pick_up_tween.affected_node = carried.art
	pick_up_tween.do_tween()


func on_target_clicked(target):
	if finished or carried == null:
		return

	if target.marker_id != carried.marker_id:
		time_left = max(time_left - start_time * wrong_click_penalty, 0.0)
		timer_bar.flash()
		nudge.affected_node = carried
		nudge.do_tween_sequence()
		return

	var tile = carried
	carried = null
	score += tile.points
	tile.z_index = 0
	tile.stop_glowing()

	var landing = target.position
	target.queue_free()

	# The destination changes every placement, so write it before playing.
	snap_tween.affected_node = tile
	snap_tween.transform_tween.end_position = landing
	await snap_tween.do_tween()

	squash.affected_node = tile.art
	await squash.do_tween_sequence()

	# The clock can run out mid animation.
	if finished:
		return

	next_tile()


func round_won():
	if finished:
		return
	finished = true
	print("score so far: ", score)
	#GameManager.win()


func round_lost():
	if finished:
		return
	finished = true
	await explode_board()
	await get_tree().create_timer(1.2).timeout
	GameManager.lose()


func explode_board():
	carried = null

	for tile in all_tiles:
		tile.freeze = false
		tile.gravity_scale = 1.0

	# Impulses applied on the same frame as the unfreeze get dropped.
	await get_tree().physics_frame

	var center = Vector2(
		get_viewport().get_visible_rect().size.x / 2.0,
		board_origin.y + GRID * cell_size / 2.0
	)
	for tile in all_tiles:
		var direction = (tile.global_position - center).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.UP
		tile.apply_central_impulse(direction * randf_range(250, 600))
		tile.angular_velocity = randf_range(-15, 15)
