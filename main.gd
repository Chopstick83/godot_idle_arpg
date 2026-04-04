extends Node2D

var slime_resource = preload("res://Enemy/slime.tscn")
var wolf_resource = preload("res://Enemy/wolf.tscn")

var stage_resource = [
	slime_resource, wolf_resource
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var num_enemies = 100

	var viewport_size = get_viewport_rect().size
	for i in range(num_enemies):
		var instance = stage_resource.pick_random().instantiate()
		instance.position = Vector2(randf_range(64, viewport_size.x - 64), randf_range(64, viewport_size.y - 64))
		add_child(instance)
