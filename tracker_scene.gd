extends Node2D


var unacquired_list: Dictionary
var special_list: Dictionary
var num: int = 310

func _ready() -> void:
	for i in 310:
		unacquired_list.set(str(i), false)
	$VBoxContainer/RichTextLabel.text = "unacquired : " + str(unacquired_list.keys()) + "\nspecial: " + str(special_list)
	$VBoxContainer/HBoxContainer/LineEdit.grab_focus()

func _physics_process(delta: float) -> void:
	if not $VBoxContainer/HBoxContainer/LineEdit.has_focus():
		$VBoxContainer/HBoxContainer/LineEdit.grab_focus()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if unacquired_list.has($VBoxContainer/HBoxContainer/LineEdit.text):
		unacquired_list.erase($VBoxContainer/HBoxContainer/LineEdit.text)
	if int($VBoxContainer/HBoxContainer/LineEdit.text) >= num:
		special_list.set(int($VBoxContainer/HBoxContainer/LineEdit.text), special_list.get_or_add(int($VBoxContainer/HBoxContainer/LineEdit.text), 0) + 1)
	$VBoxContainer/RichTextLabel.text = "unacquired : " + str(unacquired_list.keys()) + "\nspecial: " + str(special_list)
	$VBoxContainer/HBoxContainer/LineEdit.text = ""
