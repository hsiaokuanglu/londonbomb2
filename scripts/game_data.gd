class_name GameData

#current_round: int
#remaining_defuse_wire: int
#player_id_name: {"id": "name"}
#player_wire_boxes: {"id": {WIRE_DICT}}
#player_defuse_claim: {"id": int}
#player_have_bomb_claim: {"id": bool}
#player_finished_cut: {"id": bool}


var current_round: int
var remaining_defuse_wire: int
var player_id_name: Dictionary
var player_id_role: Dictionary
var player_wire_boxes: Dictionary
var player_defuse_claim: Dictionary
var player_have_bomb_claim: Dictionary
var player_finished_cut: Dictionary
var history: Dictionary

func get_ids() -> Array:
	return player_id_name.keys()

func get_data_dict():
	return Dictionary({
		"current_round": current_round,
		"remaining_defuse_wire": remaining_defuse_wire,
		"player_id_name": player_id_name,
		"player_id_role": player_id_role,
		"player_wire_boxes": player_wire_boxes,
		"player_defuse_claim": player_defuse_claim,
		"player_have_bomb_claim": player_have_bomb_claim,
		"player_finished_cut": player_finished_cut,
		"history": history
	})

func get_player_dict(id:int):
	return Dictionary({
		"player_id_name": player_id_name[id],
		"player_id_role": player_id_role[id],
		"player_wire_boxes": player_wire_boxes[id],
		"player_defuse_claim": player_defuse_claim[id],
		"player_have_bomb_claim": player_have_bomb_claim[id],
		"player_finished_cut": player_finished_cut[id]
	})

func replace_player(old_id:int, new_id:int):
	player_id_name[new_id] = player_id_name[old_id]
	player_id_role[new_id] = player_id_role[old_id]
	player_wire_boxes[new_id] = player_wire_boxes[old_id]
	player_defuse_claim[new_id]= player_defuse_claim[old_id]
	player_have_bomb_claim[new_id] = player_have_bomb_claim[old_id]
	player_finished_cut[new_id] = player_finished_cut[old_id]
	player_id_name.erase(old_id)
	player_id_role.erase(old_id)
	player_wire_boxes.erase(old_id)
	player_defuse_claim.erase(old_id)
	player_have_bomb_claim.erase(old_id)
	player_finished_cut.erase(old_id)

func init_player(id:int):
	player_id_name[id] = ""
	player_id_role[id] = ""
	player_wire_boxes[id] = Dictionary()
	player_defuse_claim[id]= 0
	player_have_bomb_claim[id] = false
	player_finished_cut[id] = false

func remove_player(id: int):
	player_id_name.erase(id)
	player_id_role.erase(id)
	player_wire_boxes.erase(id)
	player_defuse_claim.erase(id)
	player_have_bomb_claim.erase(id)
	player_finished_cut.erase(id)

func set_player_id_role(id_role: Dictionary):
	player_id_role = id_role

# wires: {id: ["defuse", "safe", "bomb"]
func set_player_wire_boxes(wires: Dictionary):
	for id in wires.keys():
		var wire_dict = Dictionary()
		for i in range(wires[id].size()):
			wire_dict[i] =  Dictionary({
				"type": wires[id][i],
				"is_cut": false,
				"variation": 1
			})
		player_wire_boxes[id] = wire_dict
