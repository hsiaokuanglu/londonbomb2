extends Panel

signal restart

func set_win_or_lose(is_winner: bool):
	if is_winner:
		$VBoxContainer/WoLLabel.text = "WIN"
	else:
		$VBoxContainer/WoLLabel.text = "LOSE"


func _on_restart_button_pressed() -> void:
	restart.emit()
