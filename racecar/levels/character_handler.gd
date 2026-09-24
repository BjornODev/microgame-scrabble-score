class_name CharacterHandler
extends Node2D


@export var character_pool: Array[RaceTrackCharacterStats]

@export_group("Appearance")
@export var character_scene: PackedScene

@export_group("Spawn Area")
# The allowed region where characters can spawn
@export var spawn_region: Rect2 = Rect2()
# Places where characters are not allowed to spawn in
@export var exclusion_shapes: Array[CollisionPolygon2D] = []
# Minimum space between characters (prevents overlap)
@export var min_character_spacing: float = 96.0
# Max times a character can try to spawn after failing to do so
@export var max_spawn_attempts: int = 50

@export_group("Placement Relative To Track")
# Minimum distance the character can be from the car
@export var min_distance_from_anchor: float = 60.0
# Maximum distance the character can be from the car
@export var max_distance_from_anchor: float = 260.0


var characters: Array[AnimatedSprite2D] = []


func spawn_characters(track_anchors: Array[Transform2D]) -> void:
	_clear_existing()

	if character_pool.is_empty():
		return

	var pool := character_pool.duplicate()
	pool.shuffle()

	var region := spawn_region
	if region.size == Vector2.ZERO:
		region = get_viewport_rect()

	var exclusion_polygons := _gather_exclusion_zone()

	for i in track_anchors.size():
		var stats: RaceTrackCharacterStats = (
			pool[i] if i < pool.size() else pool[randi() % pool.size()]
		)
		var anchor_local := to_local(track_anchors[i].origin)
		var spawn_point := _find_spawn_point(anchor_local, region, exclusion_polygons)

		var sprite := _instantiate_character()
		sprite.name = "Character%d" % i
		sprite.sprite_frames = stats.character_sprite_frames
		sprite.position = spawn_point
		add_child(sprite)

		characters.append(sprite)


func _instantiate_character() -> AnimatedSprite2D:
	if character_scene:
		var instance := character_scene.instantiate()
		if instance is AnimatedSprite2D:
			return instance
		
		instance.queue_free()
	return AnimatedSprite2D.new()


func _clear_existing() -> void:
	for character in characters:
		if is_instance_valid(character):
			character.queue_free()
	characters.clear()


func _gather_exclusion_zone() -> Array[PackedVector2Array]:
	var polygons: Array[PackedVector2Array] = []
	for shape in exclusion_shapes:
		if shape == null:
			continue
		var points := PackedVector2Array()
		for point in shape.polygon:
			points.append(to_local(shape.to_global(point)))
		polygons.append(points)
	return polygons



func _find_spawn_point(
	anchor_local: Vector2, region: Rect2, exclusion_polygons: Array[PackedVector2Array]
) -> Vector2:
	var candidate := anchor_local
	for attempt in max_spawn_attempts:
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(min_distance_from_anchor, max_distance_from_anchor)
		candidate = anchor_local + Vector2.RIGHT.rotated(angle) * distance

		if not region.has_point(candidate):
			continue
		if _is_excluded(candidate, exclusion_polygons):
			continue
		if _too_close_to_others(candidate):
			continue
		return candidate

	return candidate


func _is_excluded(point: Vector2, exclusion_polygons: Array[PackedVector2Array]) -> bool:
	for polygon in exclusion_polygons:
		if Geometry2D.is_point_in_polygon(point, polygon):
			return true
	return false


func _too_close_to_others(point: Vector2) -> bool:
	for character in characters:
		if character.position.distance_to(point) < min_character_spacing:
			return true
	return false
