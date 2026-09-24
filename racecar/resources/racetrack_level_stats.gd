class_name RacetrackLevelStats
extends Resource

@export var checkpoints: Array[CheckpointData]

# Random delay window before the QTE triggers (prevents rhythm memorization)
@export var min_delay: float = 0.5
@export var max_delay: float = 1.5
