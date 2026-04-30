extends Node
class_name SaveManager

const SETTINGS_SAVE_PATH: String = "user://settings.tres"
const USER_SAVE_PATH: String = "user://save.tres"
const SKILL_SAVE_PATH: String = "user://skill.tres"

static func save_game(data: UserSaveData) -> void:
	ResourceSaver.save(data, USER_SAVE_PATH)

static func load_game() -> UserSaveData:
	if FileAccess.file_exists(USER_SAVE_PATH):
		return ResourceLoader.load(USER_SAVE_PATH) as UserSaveData
	else:
		return UserSaveData.new()

static func save_skill(data: UserTreeData) -> void:
	ResourceSaver.save(data, SKILL_SAVE_PATH)

static func load_skill() -> UserTreeData:
	if FileAccess.file_exists(SKILL_SAVE_PATH):
		return ResourceLoader.load(SKILL_SAVE_PATH) as UserTreeData
	else:
		return UserTreeData.new()

static func save_settings(data: SettingData) -> void:
	ResourceSaver.save(data, SETTINGS_SAVE_PATH)

static func load_settings() -> SettingData:
	if FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return ResourceLoader.load(SETTINGS_SAVE_PATH) as SettingData
	else:
		return SettingData.new()
