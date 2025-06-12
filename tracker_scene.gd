extends Node2D


var set_id: Dictionary = {}
var special_list: Dictionary
var num: int = 310
var time_since_last_refresh: int = 0
var last_input: int = -1

func _ready() -> void:
	process_text()
	while($HBoxContainer/VBoxContainer/Range/Min == null and Saves.save_loaded == false):
		await get_tree().process_frame
	$HBoxContainer/VBoxContainer/SetID/SetID.text = Saves.get_or_return("Settings", "set_id", "")
	$HBoxContainer/VBoxContainer/Range/Min.text = Saves.get_or_return("Settings", "min", "1")
	$HBoxContainer/VBoxContainer/Range/Max.text = Saves.get_or_return("Settings", "max", "1")
	get_tree().root.size_changed.connect(display_changed_size)
	display_changed_size()


func _physics_process(_delta: float) -> void:
	if time_since_last_refresh > 120:
		process_text()
		time_since_last_refresh = 0
	else:
		time_since_last_refresh = time_since_last_refresh + 1


func display_changed_size() -> void:
	$HBoxContainer/VBoxContainer.size = get_tree().root.size
	$HBoxContainer.size = get_tree().root.size

func process_text(_input: String = "") -> void:
	var unacquired_list: String = "Unaquired: "
	var unacquired_num: int = 0
	var duplicates: Dictionary = {}
	var duplicates_string: String = "duplicates: "
	var out_of_range: String = "Out of Range: "
	var play_sets: String = "Playsets: "
	for i in int($HBoxContainer/VBoxContainer/Range/Max.text) - int($HBoxContainer/VBoxContainer/Range/Min.text) + 1:
		if Saves.get_or_return($HBoxContainer/VBoxContainer/SetID/SetID.text, str(i + int($HBoxContainer/VBoxContainer/Range/Min.text)), 0) == 0:
			unacquired_list = unacquired_list + " " + str(i + int($HBoxContainer/VBoxContainer/Range/Min.text))
			unacquired_num = unacquired_num + 1
	if Saves.data is Dictionary and Saves.data.has($HBoxContainer/VBoxContainer/SetID/SetID.text) and Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text] is Dictionary:
		var keys: Array = Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text].keys()
		var temp: Array = []
		for key in keys:
			temp.append(int(key))
		temp.sort()
		keys = []
		for key in temp:
			keys.append(str(key))
		for key in keys:
			if Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text][key] > 0:
				duplicates[key] = Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text][key]
			if Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text][key] >= 4:
				play_sets = play_sets + str(key) + " "
			if int(key) > int($HBoxContainer/VBoxContainer/Range/Max.text) or int(key) < int($HBoxContainer/VBoxContainer/Range/Min.text):
				out_of_range = out_of_range + " [" + str(key) + " , " + str(int(Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text][key])) + "] "
	for key in duplicates:
		if duplicates[key] > 1:
			duplicates_string = duplicates_string + " [" + str(key) + " , " + str(int(duplicates[key] - 1)) + "] "
	var final_string = ""
	if $HBoxContainer/VBoxContainer/HBoxContainer/Unacquired.button_pressed:
		final_string = final_string + unacquired_list + "\nunacquired num = " + str(int(unacquired_num))
	if $HBoxContainer/VBoxContainer/HBoxContainer/Duplicate.button_pressed:
		final_string = final_string + "\n\n" + duplicates_string
	if $HBoxContainer/VBoxContainer/HBoxContainer/OutOfRange.button_pressed:
		final_string = final_string + "\n\n" + out_of_range
	if $HBoxContainer/VBoxContainer/HBoxContainer/PlaySets.button_pressed:
		final_string = final_string + "\n\n" + play_sets
	if $HBoxContainer/VBoxContainer/HBoxContainer/AllCardsInSet.button_pressed:
		var temp: Array = []
		for card in Saves.data.get($HBoxContainer/VBoxContainer/SetID/SetID.text, ["No cards"]):
			temp.append(int(card))
		temp.sort()
		var temp_2_electric_boogalo: Dictionary = {}
		for card in temp:
			temp_2_electric_boogalo.set(card, int(Saves.get_or_return($HBoxContainer/VBoxContainer/SetID/SetID.text, str(card), "0")))
		var all_cards: String = "\n\n\n All cards: "
		for key in temp_2_electric_boogalo:
			all_cards = all_cards + " [" + str(key) + " , " + str(temp_2_electric_boogalo[key]) + "] "
		final_string = final_string + all_cards
		
	final_string = final_string + "\n\n\nLast Input: " + str(last_input)
	$HBoxContainer/VBoxContainer/RichTextLabel.text = final_string


func _on_card_submitted(new_text: String) -> void:
	if new_text != "":
		Saves.set_value($HBoxContainer/VBoxContainer/SetID/SetID.text, str(int(new_text)), int(Saves.get_or_return($HBoxContainer/VBoxContainer/SetID/SetID.text, new_text, 0) + 1))
		if Saves.get_or_return($HBoxContainer/VBoxContainer/SetID/SetID.text, new_text, 1) == 1:
			$HBoxContainer/VBoxContainer/ColorRect.color = Color.GREEN
		else:
			$HBoxContainer/VBoxContainer/ColorRect.color = Color.RED
	last_input = int(new_text)
	process_text()
	$HBoxContainer/VBoxContainer/Add.text = ""
	Saves.save_game()


func _on_card_removed(new_text: String) -> void:
	if new_text != "":
		Saves.set_value($HBoxContainer/VBoxContainer/SetID/SetID.text, str(int(new_text)), int(Saves.get_or_return($HBoxContainer/VBoxContainer/SetID/SetID.text, new_text, 0) -1))
	last_input = int(new_text)
	process_text()
	$HBoxContainer/VBoxContainer/Remove.text = ""
	Saves.save_game()

func _on_copy_all_button_pressed() -> void:
	DisplayServer.clipboard_set(str(Saves.data))


func _on_copy_set_pressed() -> void:
		if Saves.data is Dictionary and Saves.data.has($HBoxContainer/VBoxContainer/SetID/SetID.text) and Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text] is Dictionary:
			DisplayServer.clipboard_set(str(Saves.data[$HBoxContainer/VBoxContainer/SetID/SetID.text]))


func set_new_card_display(enabled: bool) -> void:
	$HBoxContainer/VBoxContainer/ColorRect.visible = enabled


func set_settings(_text: String) -> void:
	Saves.set_value("Settings", "set_id", $HBoxContainer/VBoxContainer/SetID/SetID.text)
	Saves.set_value("Settings", "min", $HBoxContainer/VBoxContainer/Range/Min.text)
	Saves.set_value("Settings", "max", $HBoxContainer/VBoxContainer/Range/Max.text)
	Saves.save_game()
