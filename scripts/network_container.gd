extends VBoxContainer

signal join_game
signal set_player_name(p_name: String)
signal start_game
signal on_reconnect(p_name: String)

func _on_join_pressed() -> void:
	join_game.emit()

func _on_name_enter_button_pressed() -> void:
	$LobbyContainer.show()
	set_player_name.emit(_get_entered_name())

func _get_entered_name():
	return $SettingsContainer/NameCon/EnterName.text

func set_connection_status_str(message):
	$ConnectionStatusLabel.text = message

# easier debug
func dev_set_name(p_name: String):
	$SettingsContainer/NameCon/EnterName.set_text(p_name)
	$SettingsContainer/NameCon/NameEnterButton.emit_signal("pressed")

func set_player_list(p_list: Array):
	$LobbyContainer/PlayerList.clear()
	for p_name in p_list:
		$LobbyContainer/PlayerList.add_item(p_name)

func set_start_game_button(is_vis: bool):
	if is_vis:
		$LobbyContainer/StartButton.show()
	else:
		$LobbyContainer/StartButton.hide()

func joined_lobby():
	$Join.hide()
	$SettingsContainer.show()

func show_reconnect():
	$ReconnectButton.show()

func _on_start_button_pressed() -> void:
	start_game.emit()


func _on_reconnect_button_pressed() -> void:
	on_reconnect.emit(_get_entered_name())
