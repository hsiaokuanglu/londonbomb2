extends Control

var client_id:int
signal check_wire(client_id: int)

#func _ready():
	#dev()

func dev():
	var wire_dict = Dictionary({
		0: {
			"type": "defuse",
			"is_cut": false,
			"variation": 1
		},
		1: {
			"type": "safe",
			"is_cut": true,
			"variation": 2
		},
		2: {
			"type": "defuse",
			"is_cut": true,
			"variation": 2
		},
		3: {
			"type": "bomb",
			"is_cut": false,
			"variation": 1
		},
		4: {
			"type": "safe",
			"is_cut": false,
			"variation": 1
		}
	})
	$WireBox.set_player_card_wire(wire_dict)

func set_player_card_wire(wire_dict: Dictionary):
	$WireBox.set_player_card_wire(wire_dict)
	
func cut_player_card_wire(wire_id: int):
	$WireBox.update_cut_wire(wire_id)

func set_have_bomb_claim(claim: bool):
	if claim:
		$VBoxContainer/ClaimUI/BombCon/HaveBomb.text = "I have bomb"
	else:
		$VBoxContainer/ClaimUI/BombCon/HaveBomb.text = "No bomb"

func set_defuse_claim(claim: int):
	$VBoxContainer/ClaimUI/DWireCon/Count.text = str(claim)

func set_id_name(_client_id, p_name):
	client_id = _client_id
	$VBoxContainer/Name.text = p_name
	
func set_finished_cut(had_cut: bool):
	if had_cut:
		$FinishedCutLabel.show()
	else:
		$FinishedCutLabel.hide()


func disable_check_button():
	$VBoxContainer/CheckButton.hide()

func _on_check_button_pressed() -> void:
	check_wire.emit(client_id)
