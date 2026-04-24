extends Control

@onready var start_button: Button = $MainMenu/VBoxContainer/StartButton
@onready var options_button: Button = $MainMenu/VBoxContainer/OptionsButton
@onready var exit_button: Button = $MainMenu/VBoxContainer/ExitButton

@onready var language_label: Label = $Options/VBoxContainer/LanguageLabel
@onready var language_options: OptionButton = $Options/VBoxContainer/LanguageOptions
@onready var back_button: Button = $Options/VBoxContainer/BackButton

@onready var main_menu: Panel = $MainMenu
@onready var options: Panel = $Options

const LANGUAGE_KEY = ["en_US", "ko_KR"]

func _ready() -> void:
	update_ui_text()
	for key in LANGUAGE_KEY:
		language_options.add_item(tr("LANGUAGE_NAME_" + key.to_upper()))

func update_ui_text():
	start_button.text = tr("START_GAME")
	options_button.text = tr("OPTIONS")
	exit_button.text = tr("EXIT_GAME")
	language_label.text = tr("LANGUAGE")
	back_button.text = tr("BACK")	

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://SkillTree/skill_tree.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	options.show()
	main_menu.hide()

func _on_back_button_pressed() -> void:
	options.hide()
	main_menu.show()

func _on_language_options_item_selected(index: int) -> void:
	TranslationServer.set_locale(LANGUAGE_KEY[index])
	update_ui_text()
