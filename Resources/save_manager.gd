class_name SaveManager
extends Node

const SAVE_PATH: String = "user://save.tres"

static func save_game(data: UserSaveData) -> void:
	ResourceSaver.save(data, SAVE_PATH)

static func load_game() -> UserSaveData:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as UserSaveData
	else:
		return UserSaveData.new()
