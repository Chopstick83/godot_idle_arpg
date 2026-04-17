extends Node2D

@export var hp = 100
@export var exp = 20

signal died(exp: int)

func enemy_damaged(damage: float):
	if damage >= hp:
		died.emit(exp)
		queue_free()
	else:
		hp -= damage
