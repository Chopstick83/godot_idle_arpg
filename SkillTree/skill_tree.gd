extends Control
class_name SkillTree

@onready var panel: Panel = $Panel
@onready var extend_time: SkillNode = $Panel/ExtendTime

@onready var return_to_main_button: Button = $Panel/ReturnToMainButton
@onready var battle_start_button: Button = $BattleStartButton

var user_tree_data: UserTreeData

func _on_return_to_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_battle_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _ready() -> void:
	return_to_main_button.text = tr("RETURN_TO_MAIN")
	battle_start_button.text = tr("START_BATTLE")

	user_tree_data = SaveManager.load_skill()
	var skill_nodes = panel.find_children("*", "SkillNode", true, false)
	for child in skill_nodes:
		child.save_requested.connect(_on_child_save_requested)
		if user_tree_data.skills.get(child.id):
			child.level = user_tree_data.skills[child.id]

func _on_child_save_requested(id: String, level: int):
	if id:
		user_tree_data.skills[id] = level
	SaveManager.save_skill(user_tree_data)
