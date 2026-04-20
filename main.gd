extends Node2D

@onready var attack_timer: Timer = $AttackTimer
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var attack_sound_player: AudioStreamPlayer = $AttackSoundPlayer

@onready var stage_timer: Timer = $StageTimer
@onready var stage_timer_progress_bar: ProgressBar = $StageTimerProgressBar
@onready var stage_time_left: Label = $StageTimerProgressBar/StageTimeLeft

@onready var result_panel: Panel = $ResultPanel
@onready var exp_label: Label = $ResultPanel/ExpLabel

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

var player_exp = 0
var wait_time = 5.0

# Debug
func _draw() -> void:
	if stage_timer.time_left > 0:
		draw_circle(current_mouse_pos, mouse_radius, Color.AQUA, false, 2)

func _process(delta: float) -> void:
	stage_timer_progress_bar.value = stage_timer.time_left
	stage_time_left.text = "%05.2f" % stage_timer.time_left
	queue_redraw()

func _physics_process(delta: float) -> void:
	area_2d.global_position = current_mouse_pos

func _ready() -> void:
	collision_shape_2d.shape.radius = mouse_radius

	reset_enemies()
	reset_timer(wait_time)

func reset_enemies():
	var num_enemies = 100
	var viewport_size = get_viewport_rect().size
	for i in range(num_enemies):
		var enemy_instance = stage_resource.pick_random().instantiate()
		enemy_instance.position = Vector2(randf_range(64, viewport_size.x - 64), randf_range(64, viewport_size.y - 64))
		enemy_instance.died.connect(get_exp)
		add_child(enemy_instance)
		enemy_instance.add_to_group("spawned_enemies")

func reset_timer(wait_time: float):
	stage_timer_progress_bar.max_value = wait_time
	stage_timer_progress_bar.value = wait_time
	stage_timer.start(wait_time)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_mouse_pos = get_global_mouse_position()

func _on_attack_timer_timeout() -> void:
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

func get_exp(exp: int):
	player_exp += exp
	print(player_exp)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not enemies_in_area.has(area):
		enemies_in_area.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if enemies_in_area.has(area):
		enemies_in_area.erase(area)

func _on_stage_timer_timeout() -> void:
	get_tree().call_group("spawned_enemies", "queue_free")
	exp_label.text = "Earned Exp: %.0f" % player_exp
	result_panel.show()

func _on_continue_battle_button_pressed() -> void:
	result_panel.hide()
	reset_enemies()
	reset_timer(wait_time)

func _on_return_to_base_button_pressed() -> void:
	get_tree().change_scene_to_file("res://SkillTree/skill_tree.tscn")
