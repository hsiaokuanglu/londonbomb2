class_name GameLogic

var game_data = GameData.new()
# role types
const ROLE_GOOD = "Good Guy"
const ROLE_BAD = "Bad Guy"
# wire types
var defuse_type = "defuse"
var safe_type = "safe"
var bomb_type = "bomb"
# wire_results
const BOMB_DEFUSED = "bomb_defused"
const BOMB_EXPLODES = "bomb_explodes"
const NEXT_ROUND = "next_round"
const NOT_ALL_HAS_CUT = "not_all_has_cut"
var server: Variant
# timer time
const ROUND_TIME_SEC = 4
const ROUND_TIMEOUT_SEC = 1
const RECAP_TIME_SEC = 2

func set_server(_server):
	server = _server

func next_round():
	# get dead wires
	var dead_wires = []
	for i in range(1, 5):
		for cut_hist in game_data.history[i].values():
			dead_wires.append(cut_hist["cut_wire"]["wire_type"])
	#
	game_data.current_round -= 1
	# init wires
	var wires = init_wire_pool(game_data.get_ids())
	# remove dead wires (already cut last round)
	for i in range(dead_wires.size()):
		wires.erase(dead_wires.pop_front())
	# deal new wires
	var dealt_wires = deal_wire(game_data.get_ids(), wires, game_data.current_round)
	game_data.set_player_wire_boxes(dealt_wires)
	# reset finish cut, claims
	for id in game_data.player_finished_cut.keys():
		game_data.player_finished_cut[id] = false
		game_data.player_have_bomb_claim[id] = false
		game_data.player_defuse_claim[id] = 0

func start_game():
	game_data.current_round = 4
	# set remaining defuse wire count = player count
	game_data.remaining_defuse_wire = game_data.get_ids().size()
	# init and assign roles to players
	var roles = set_roles(game_data.get_ids())
	game_data.set_player_id_role(roles)
	# reset finished cut, claims
	for id in game_data.get_ids():
		game_data.player_finished_cut[id] = false
		game_data.player_have_bomb_claim[id] = false
		game_data.player_defuse_claim[id] = 0
	# init history
	for i in range(4, 0, -1):
		game_data.history[i] = Dictionary()

func set_roles(ids: Array) -> Dictionary:
	var rtn_role = Dictionary()
	var role_pool = []
	var num_players = ids.size()
	if 7 <= num_players:
		for _i in range(5):
			role_pool.append(ROLE_GOOD)
		for _i in range(3):
			role_pool.append(ROLE_BAD)
	elif 6 <= num_players:
		for _i in range(4):
			role_pool.append(ROLE_GOOD)
		for _i in range(2):
			role_pool.append(ROLE_BAD)
	elif 4 <= num_players:
		for _i in range(3):
			role_pool.append(ROLE_GOOD)
		for _i in range(2):
			role_pool.append(ROLE_BAD)
	role_pool.shuffle()
	ids.shuffle()
	for i in range(num_players):
		rtn_role[ids[i]] = role_pool[i]

	return rtn_role

func init_wire_pool(ids: Array) -> Array:
	var num_players = ids.size()
	var num_defuse_wire = num_players
	var num_safe_wire = num_players * 5 - num_defuse_wire - 1
	var num_bomb = 1
	var wire_pool = []
	for _i in range(num_defuse_wire):
		wire_pool.append("defuse")
	for _i in range(num_safe_wire):
		wire_pool.append("safe")
	for _i in range(num_bomb):
		wire_pool.append("bomb")
	return wire_pool

func deal_wire(ids: Array, wires: Array, game_round: int):
	wires.shuffle()
	var dealt_id_wires = Dictionary()
	for id in ids:
		dealt_id_wires[id] = []
		for i in range(game_round + 1):
			dealt_id_wires[id].append(wires.pop_front())
	
	return dealt_id_wires

#	4 (round_num): {
#		"name1": {
#			"cut_wire": {
#				"being_cut_name": String
#				"wire_type": String
#			} 
#		},
#...
func update_cut_history(cutter_id: int, being_cut_id: int, wire_type: String):
	var cutter_name = game_data.player_id_name[cutter_id]
	var being_cut_name = game_data.player_id_name[being_cut_id]
	var cur_round = game_data.current_round
	var cut_hist = Dictionary({
		"cut_wire": {
			"being_cut_name": being_cut_name,
			"wire_type": wire_type
		}
	})
	game_data.history[cur_round][cutter_name] = cut_hist

func cut_wire_logic(cutter_id: int, being_cut_id:int, wire_id: int):
	game_data.player_finished_cut[cutter_id] = true
	var wire = game_data["player_wire_boxes"][being_cut_id][wire_id]
	game_data["player_wire_boxes"][being_cut_id][wire_id]["is_cut"] = true
	var wire_type = wire["type"]
	update_cut_history(cutter_id, being_cut_id, wire_type)
	if wire_type == bomb_type:
		return BOMB_EXPLODES
	elif wire_type == defuse_type:
		game_data.remaining_defuse_wire -= 1
		if game_data.remaining_defuse_wire == 0:
			return BOMB_DEFUSED
	#elif wire_type == safe_type:
		#return ""
	return ""

func check_next_round() -> String:
	# check if all defuse is cut
	if game_data.remaining_defuse_wire == 0:
		return BOMB_DEFUSED
	# check if all players have cut
	var all_fin_cut = true
	for fin_cut in game_data.player_finished_cut.values():
		all_fin_cut = all_fin_cut and fin_cut
	if all_fin_cut and game_data.current_round == 1 and game_data.remaining_defuse_wire > 0:
		return BOMB_EXPLODES
	if all_fin_cut:
		return NEXT_ROUND
	else:
		return NOT_ALL_HAS_CUT


func timer_timeout_random_cut():

	var players = game_data.get_non_cut_players()
	players.shuffle()
	var uncut_wires = game_data.get_uncut_wires()
	uncut_wires.shuffle()
	for i in range(players.size()):
		for j in range(uncut_wires.size()):
			var being_cut_id = uncut_wires[j]["being_cut_id"]
			var wire_id = uncut_wires[j]["wire_id"]
			# can not cut own wire
			var _dev_hack = game_data.player_wire_boxes[being_cut_id][wire_id]["type"] == "safe" or \
							game_data.player_wire_boxes[being_cut_id][wire_id]["type"] == "defuse" 
			if not being_cut_id == players[i]:# and dev_hack:
				uncut_wires.pop_at(j) # remove it from uncut wires
				print("cutter: " , str(players[i]),
					", being_cut: ", str(being_cut_id),
					", wire_type: ", str(game_data.player_wire_boxes[being_cut_id][wire_id]["type"]))
				#cutter_id: int, being_cut_id:int, wire_id: int
				server.cut_wire(players[i], being_cut_id, wire_id)
				break
