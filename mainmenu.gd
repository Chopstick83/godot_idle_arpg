extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://SkillTree/skill_tree.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
