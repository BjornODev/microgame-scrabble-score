extends Node2D

@onready var enemy_amt : int = int(get_parent().difficulty * 5 + 4)
@onready var sfx_villager_dies: AudioStreamPlayer = $SfxVillagerDies
@onready var sfx_ogre_dies: AudioStreamPlayer = $SfxOgreDies

func enemy_died():
	sfx_ogre_dies.play(0.9)
	get_parent().increase_count()
	enemy_amt -= 1
	if enemy_amt == 0:
		get_parent().win()

func villager_died():
	get_parent().decrease_count()
	sfx_villager_dies.play(0.7)
