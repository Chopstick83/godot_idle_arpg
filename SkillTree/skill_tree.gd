extends Control
class_name SkillTree

@onready var panel: Panel = $Panel
@onready var extend_time: SkillNode = $Panel/ExtendTime

var user_tree_data: UserTreeData

func _on_return_to_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_battle_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _ready() -> void:
	for child in panel.get_children():
		if child is SkillNode:
			child.save_requested.connect(_on_child_save_requested)
	user_tree_data = SaveManager.load_skill()

func _on_child_save_requested():
	SaveManager.save_skill(user_tree_data)
