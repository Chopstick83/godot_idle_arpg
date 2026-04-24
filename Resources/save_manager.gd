class_name SaveManager
extends Node

const SETTINGS_PATH: String = "user://settings.tres"
const SAVE_PATH: String = "user://save.tres"

static func save_game(data: UserSaveData) -> void:
	ResourceSaver.save(data, SAVE_PATH)

static func load_game() -> UserSaveData:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as UserSaveData
	else:
		return UserSaveData.new()

static func save_settings(data: SettingData) -> void:
	ResourceSaver.save(data, SETTINGS_PATH)

static func load_settings() -> SettingData:
	if FileAccess.file_exists(SETTINGS_PATH):
		return ResourceLoader.load(SETTINGS_PATH) as SettingData
	else:
		return SettingData.new()
