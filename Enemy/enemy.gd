extends Node2D

@export var hp = 100

func enemy_damaged(damage: float):
	if damage >= hp:
		queue_free()
	else:
		hp -= damage
