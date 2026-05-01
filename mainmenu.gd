extends Control

@onready var start_button: Button = $MainMenu/VBoxContainer/StartButton
@onready var options_button: Button = $MainMenu/VBoxContainer/OptionsButton
@onready var exit_button: Button = $MainMenu/VBoxContainer/ExitButton

@onready var language_label: Label = $Options/VBoxContainer/LanguageLabel
@onready var language_options: OptionButton = $Options/VBoxContainer/LanguageOptions
@onready var back_button: Button = $Options/VBoxContainer/BackButton

@onready var main_menu: Panel = $MainMenu
@onready var options: Panel = $Options

@onready var volume_label: Label = $Options/VBoxContainer/VolumeLabel
@onready var bgm_volume_label: Label = $Options/VBoxContainer/BgmVolumeLabel
@onready var sfx_volume_label: Label = $Options/VBoxContainer/SfxVolumeLabel

@onready var bgm_volume_h_slider: HSlider = $Options/VBoxContainer/BgmVolumeHSlider
@onready var sfx_volume_h_slider: HSlider = $Options/VBoxContainer/SfxVolumeHSlider

@onready var resolution_label: Label = $Options/VBoxContainer/ResolutionLabel
@onready var resolution_options: OptionButton = $Options/VBoxContainer/ResolutionOptions
@onready var full_screen_check_box: CheckBox = $Options/VBoxContainer/FullScreenCheckBox

const LANGUAGE_KEY = ["en_US", "ko_KR"]
const RESOLUTIONS = {
	"2560x1440": Vector2i(2560,1440), # 21.30%
	"1920x1080": Vector2i(1920,1080), # 53.73%
	"1366x768": Vector2i(1366,768), # 2.52%
	"1280x720": Vector2i(1280,720), # 여기까지가 16:9 해상도
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}

var settings_data: SettingData

func _ready() -> void:
	for key in LANGUAGE_KEY:
		language_options.add_item(tr("LANGUAGE_NAME_" + key.to_upper()))
	for res in RESOLUTIONS:
		resolution_options.add_item(res)
	
	settings_data = SaveManager.load_settings()
	var idx = LANGUAGE_KEY.find(settings_data.language)
	if idx < 0:
		idx = 0
	if language_options.selected != idx:
		language_options.selected = idx

	bgm_volume_h_slider.set_value_no_signal(settings_data.bgm)
	sfx_volume_h_slider.set_value_no_signal(settings_data.sfx)

	var lang = LANGUAGE_KEY[idx]
	TranslationServer.set_locale(lang)
	update_ui_text()

func update_ui_text():
	start_button.text = tr("START_GAME")
	options_button.text = tr("OPTIONS")
	exit_button.text = tr("EXIT_GAME")
	language_label.text = tr("LANGUAGE")
	back_button.text = tr("BACK")
	volume_label.text = tr("VOLUME")
	bgm_volume_label.text = tr("VOLUME_BGM")
	sfx_volume_label.text = tr("VOLUME_SFX")
	resolution_label.text = tr("RESOLUTION")
	full_screen_check_box.text = tr("FULL_SCREEN")

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
	var lang = LANGUAGE_KEY[index]
	TranslationServer.set_locale(lang)

	update_ui_text()
	settings_data.language = lang
	SaveManager.save_settings(settings_data)

func _on_bgm_volume_h_slider_value_changed(value: float) -> void:
	settings_data.bgm = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value))
	SaveManager.save_settings(settings_data)

func _on_sfx_volume_h_slider_value_changed(value: float) -> void:
	settings_data.sfx = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	SaveManager.save_settings(settings_data)

func _on_resolution_options_item_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTIONS.values()[index])

func _on_full_screen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
