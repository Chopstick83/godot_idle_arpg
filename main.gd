extends Node2D

@onready var timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var attack_sound_player: AudioStreamPlayer = $AttackSoundPlayer

var slime_resource = preload("res://Enemy/slime.tscn")
var wolf_resource = preload("res://Enemy/wolf.tscn")

var stage_resource = [
	slime_resource, wolf_resource
]

@export var attack_effect_scene: PackedScene # 인스펙터에서 공격 이펙트 씬 할당

var enemies_in_area: Array[Node2D] = []
var is_mouse_hovering: bool = false
const mouse_radius = 100
var current_mouse_pos: Vector2

# Debug
func _draw() -> void:
	draw_circle(current_mouse_pos, mouse_radius, Color.AQUA, false, 2)

func _process(delta: float) -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	area_2d.global_position = current_mouse_pos

func _ready() -> void:
	var num_enemies = 100
	collision_shape_2d.shape.radius = mouse_radius

	var viewport_size = get_viewport_rect().size
	for i in range(num_enemies):
		var enemy_instance = stage_resource.pick_random().instantiate()
		enemy_instance.position = Vector2(randf_range(64, viewport_size.x - 64), randf_range(64, viewport_size.y - 64))
		add_child(enemy_instance)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_mouse_pos = get_global_mouse_position()

func _on_timer_timeout() -> void:
	strike_enemies()

func strike_enemies() -> void:
	for enemy in enemies_in_area:
		# 적이 도중에 삭제되었을(죽었을) 경우를 대비한 안전 장치
		if not is_instance_valid(enemy):
			continue 
			
		var effect = attack_effect_scene.instantiate()
		
		# 이펙트를 씬 트리에 추가 (적의 자식으로 넣으면 적이 죽을 때 이펙트도 같이 사라지므로, 보통은 현재 씬(최상위)에 추가)
		get_tree().current_scene.add_child(effect)
		
		# 이펙트의 위치를 적의 위치로 설정
		effect.global_position = enemy.global_position
		
		# 공격 이펙트 추가 보정
		effect.scale *= 0.6
		#effect.global_position.y -= 10
		
		# 공격 사운드 처리
		attack_sound_player.play()
		
		var attack_damage = 30
		enemy.get_parent().enemy_damaged(attack_damage)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not enemies_in_area.has(area):
		enemies_in_area.append(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if enemies_in_area.has(area):
		enemies_in_area.erase(area)
