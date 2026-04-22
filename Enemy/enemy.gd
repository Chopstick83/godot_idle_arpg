extends Node2D

@export var hp = 100
@export var xp = 20

signal died(xp: int)

func enemy_damaged(damage: float):
	if damage >= hp:
		died.emit(xp)
		queue_free()
	else:
		hp -= damage
