extends Node


# for DUEL
var current_level := 1

var last_score := 0
var high_score := 0
var jail_lock_picked: bool = false

const SAVE_PATH := "user://high_score.save"

func _ready():
	print("[Global] Autoload ready. Loading high score...")
	clear_saved_high_score()  # 🔥 TEMP: delete existing file once
	load_high_score()

func update_score(score: int):
	last_score = score
	if score > high_score:
		high_score = score
		save_high_score()
		print("[Global] New high score saved:", high_score)
	else:
		print("[Global] Final score:", score, " | High score:", high_score)

func save_high_score():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()
		print("[Global] High score saved to file:", high_score)
	else:
		print("[Global] ERROR: Could not open file to save high score.")

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var loaded_score := file.get_32()
			file.close()
			high_score = max(0, loaded_score)  # prevent negative values
			print("[Global] Loaded high score:", high_score)
		else:
			print("[Global] ERROR: Could not open file for reading.")
	else:
		high_score = 0
		print("[Global] No save file found. Starting at 0.")

func clear_saved_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[Global] Old save file deleted. Starting fresh.")
