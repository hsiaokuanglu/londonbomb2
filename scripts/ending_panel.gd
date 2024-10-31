extends Panel

signal restart

func set_win_or_lose(is_winner: bool):
	if is_winner:
		$VBoxContainer/WoLLabel.set_text("YOU WIN")
	else:
		$VBoxContainer/WoLLabel.set_text("YOU LOSE")

func set_result(game_result: String):
	if game_result == GameLogic.BOMB_DEFUSED:
		$VBoxContainer/Result.set_text("Bomb defused!")
	elif game_result == GameLogic.BOMB_EXPLODES:
		$VBoxContainer/Result.set_text("Bomb exploded!")

func _on_restart_button_pressed() -> void:
	restart.emit()
