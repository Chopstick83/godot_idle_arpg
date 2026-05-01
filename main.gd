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
@onready var continue_battle_button: Button = $ResultPanel/ContinueBattleButton
@onready var return_to_base_button: Button = $ResultPanel/ReturnToBaseButton

@onready var exp_progress_bar: ProgressBar = $ExpProgressBar
@onready var exp_text: Label = $ExpProgressBar/ExpText

var mummy_resource = preload("res://Enemy/mummy.tscn")
var scorpion_resource = preload("res://Enemy/scorpion.tscn")
var slime_resource = preload("res://Enemy/slime.tscn")
var snake_resource = preload("res://Enemy/snake.tscn")
var spider_resource = preload("res://Enemy/spider.tscn")
var wolf_resource = preload("res://Enemy/wolf.tscn")

var stage_resource = [
	mummy_resource, scorpion_resource, slime_resource, snake_resource, spider_resource, wolf_resource
]

@export var attack_effect_scene: PackedScene # 인스펙터에서 공격 이펙트 씬 할당

var enemies_in_area: Array[Node2D] = []
var is_mouse_hovering: bool = false
# 배열 index 0은 노드에 존재하지 않는 기본 값
var attack_radius_array = [10.0, 30.0, 50.0, 75.0, 100.0]
var attack_radius_level = 0
var wait_time_array = [5.0, 6.0, 7.0, 8.5, 10.0]
var wait_time_level = 0
var attack_wait_time_array = [0.5, 0.4, 0.3, 0.2, 0.1]
var attack_wait_time_level = 0
var current_mouse_pos: Vector2

var exp_label_base: String
var user_save_data: UserSaveData
var user_tree_data: UserTreeData

func _draw() -> void:
	if stage_timer.time_left > 0:
		draw_circle(current_mouse_pos, attack_radius_array[attack_radius_level], Color.AQUA, false, 2)

func _process(_delta: float) -> void:
	var time_str = "%05.2f" % stage_timer.time_left
	stage_timer_progress_bar.value = stage_timer.time_left
	stage_time_left.text = tr("STAGE_COUNTER").format([time_str])
	queue_redraw()

func _physics_process(_delta: float) -> void:
	area_2d.global_position = current_mouse_pos

func _ready() -> void:
	continue_battle_button.text = tr("CONTINUE_BATTLE")
	return_to_base_button.text = tr("RETURN_TO_BASE")
	exp_label_base = tr("EARNED_EXP")
	
	user_tree_data = SaveManager.load_skill()
	attack_radius_level = user_tree_data.skills.get("EXPAND_ATTACK")
	attack_wait_time_level = user_tree_data.skills.get("FASTER_AS")
	collision_shape_2d.shape.radius = attack_radius_array[attack_radius_level]
	attack_timer.wait_time = attack_wait_time_array[attack_wait_time_level]

	user_save_data = SaveManager.load_game()
	exp_progress_bar.max_value = user_save_data.max_xp
	exp_progress_bar.value = user_save_data.xp

	reset_enemies()
	wait_time_level = user_tree_data.skills.get("EXTEND_TIME")
	reset_timer(wait_time_array[wait_time_level])

func reset_enemies():
	var num_enemies = 100
	var viewport_size = get_viewport_rect().size
	for i in range(num_enemies):
		var enemy_instance = stage_resource.pick_random().instantiate()
		enemy_instance.position = Vector2(randf_range(64, viewport_size.x - 64), randf_range(64, viewport_size.y - 64))
		enemy_instance.died.connect(get_exp)
		add_child(enemy_instance)
		enemy_instance.add_to_group("spawned_enemies")

func reset_timer(_wait_time: float):
	stage_timer_progress_bar.max_value = _wait_time
	stage_timer_progress_bar.value = _wait_time
	stage_timer.start(_wait_time)

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

func get_exp(_exp: int):
	user_save_data.xp += _exp
	if user_save_data.xp >= exp_progress_bar.max_value:
		user_save_data.xp -= exp_progress_bar.max_value
		user_save_data.level += 1
		user_save_data.max_xp += 100
		exp_progress_bar.max_value += 100
		
		update_exp_text(user_save_data.xp)

	# 이 부분 적 사망시에 호출되는 시그널이라 tween과 update_text로 사용하지 않도록 수정 필요
	var tween = create_tween()
	tween.tween_property(exp_progress_bar, "value", user_save_data.xp, 0.1).set_trans(Tween.TRANS_SINE)
	
func _on_exp_progress_bar_value_changed(value: float) -> void:
	update_exp_text(value)

func update_exp_text(value):
	var level_text = tr("LEVEL").format([user_save_data.level])
	exp_text.text = "%s - %d / %d" % [level_text, int(value), exp_progress_bar.max_value]

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not enemies_in_area.has(area):
		enemies_in_area.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if enemies_in_area.has(area):
		enemies_in_area.erase(area)

func _on_stage_timer_timeout() -> void:
	get_tree().call_group("spawned_enemies", "queue_free")
	exp_label.text = exp_label_base.format([int(user_save_data.xp)])
	result_panel.show()
	SaveManager.save_game(user_save_data)

func _on_continue_battle_button_pressed() -> void:
	result_panel.hide()
	reset_enemies()
	reset_timer(wait_time_array[wait_time_level])

func _on_return_to_base_button_pressed() -> void:
	get_tree().change_scene_to_file("res://SkillTree/skill_tree.tscn")
