extends Control
class_name SkillTree

@onready var panel: Panel = $Panel
@onready var extend_time: SkillNode = $Panel/ExtendTime

func _on_return_to_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_battle_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
