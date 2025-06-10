extends Node2D


var special_list: Dictionary
var num: int = 310
var time_since_last_refresh: int = 0

func _ready() -> void:
	process_text()


func _physics_process(delta: float) -> void:
	if time_since_last_refresh > 120:
		process_text()
		time_since_last_refresh = 0
	else:
		time_since_last_refresh = time_since_last_refresh + 1


func process_text(_input: String = "") -> void:
	var unacquired_list: String = "Unaquired: "
	var extras: Dictionary = {}
	var extras_string: String = "extras: "
	var out_of_range: String = "Out of Range: "
	for i in int($VBoxContainer/Range/Max.text) - int($VBoxContainer/Range/Min.text) + 1:
		if Saves.get_or_return($VBoxContainer/SetID/SetID.text, str(i + int($VBoxContainer/Range/Min.text)), 0) == 0:
			unacquired_list = unacquired_list + " " + str(i + int($VBoxContainer/Range/Min.text))
	if Saves.data is Dictionary and Saves.data.has($VBoxContainer/SetID/SetID.text) and Saves.data[$VBoxContainer/SetID/SetID.text] is Dictionary:
		for key in Saves.data[$VBoxContainer/SetID/SetID.text].keys():
			if Saves.data[$VBoxContainer/SetID/SetID.text][key] > 0:
				extras[key] = Saves.data[$VBoxContainer/SetID/SetID.text][key]
			if int(key) > int($VBoxContainer/Range/Max.text) or int(key) < int($VBoxContainer/Range/Min.text):
				out_of_range = out_of_range + "[" + str(key) + ", " + str(Saves.data[$VBoxContainer/SetID/SetID.text][key]) + "] "
	for key in extras:
		if extras[key] > 1:
			extras_string = extras_string + " [" + str(key) + ", " + str(extras[key] - 1) + "] " 
	$VBoxContainer/RichTextLabel.text = (
		unacquired_list + "\n" + extras_string + "\n" + out_of_range + "\n\n\n All cards: " + str(Saves.data.get($VBoxContainer/SetID/SetID.text, "No cards"))
	)


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text != "":
		Saves.set_value($VBoxContainer/SetID/SetID.text, new_text, int(Saves.get_or_return($VBoxContainer/SetID/SetID.text, new_text, 0) + 1))
	process_text()
	$VBoxContainer/LineEdit.text = ""
	Saves.save_game()
