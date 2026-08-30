extends Node
const SAVE_PATH := "user://career_xi_slot_1.json"
func save(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	return parsed if parsed is Dictionary else {}
func has_save() -> bool: return FileAccess.file_exists(SAVE_PATH)
func erase() -> void:
	if has_save(): DirAccess.remove_absolute(SAVE_PATH)
