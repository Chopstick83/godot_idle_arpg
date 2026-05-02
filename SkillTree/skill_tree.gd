extends Control
class_name SkillTree

@onready var panel: Panel = $Panel
@onready var return_to_main_button: Button = $Panel/ReturnToMainButton
@onready var battle_start_button: Button = $BattleStartButton
@onready var point_left_label: Label = $Panel/PointLeftLabel
@onready var reset_skill_point_button: Button = $Panel/ResetSkillPointButton

var user_tree_data: UserTreeData

func _on_return_to_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_battle_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _ready() -> void:
	return_to_main_button.text = tr("RETURN_TO_MAIN")
	battle_start_button.text = tr("START_BATTLE")
	reset_skill_point_button.text = tr("RESET_SKILL_POINTS")

	user_tree_data = SaveManager.load_skill()

	var skill_nodes = panel.find_children("*", "SkillNode", true, false)
	for child in skill_nodes:
		child.save_requested.connect(_on_child_save_requested)
		child.point_increased.connect(_on_child_point_increased)
		child.point_decreased.connect(_on_child_point_decreased)
		if user_tree_data.skills.get(child.id):
			child.level = user_tree_data.skills[child.id]

	update_unspend()

func _on_child_save_requested(id: String, level: int):
	if id:
		user_tree_data.skills[id] = level
	SaveManager.save_skill(user_tree_data)

func _on_child_point_decreased():
	user_tree_data.unspend -= 1
	update_unspend()
	SaveManager.save_skill(user_tree_data)

func _on_child_point_increased():
	user_tree_data.unspend += 1
	update_unspend()
	SaveManager.save_skill(user_tree_data)

func update_unspend():
	point_left_label.text = tr("SKILL_POINT_UNUSED").format([user_tree_data.unspend])

func _on_temp_level_reset_button_pressed() -> void:
	var game_data = SaveManager.load_game()
	game_data.level = 1
	game_data.xp = 0
	game_data.max_xp = 100
	SaveManager.save_game(game_data)
	
	var skill_data = SaveManager.load_skill()
	skill_data.unspend = 0
	skill_data.skills = {}
	SaveManager.save_skill(skill_data)

func _on_reset_skill_point_button_pressed() -> void:
	pass # Replace with function body.
