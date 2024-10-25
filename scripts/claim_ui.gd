extends Control

signal declare_pressed
signal have_bomb_presssed


func _on_declare_button_pressed() -> void:
	declare_pressed.emit()

func _on_have_bomb_button_pressed() -> void:
	have_bomb_presssed.emit()
