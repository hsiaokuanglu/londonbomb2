extends Node

var multiplayer_peer = WebSocketMultiplayerPeer.new()
var port = 8765
var game_started = false
var game_paused = false
var disconnected_ids: Array

# game data
var game_logic: GameLogic
var game_data: GameData

@onready
var round_timer = $RoundTimer
@export
var delay_timer: Timer
@export
var last_cut_timer: Timer
@export
var defuse_timer: Timer
@export
var recap_timer: Timer

func _ready():
	_start_server()
	round_timer.set_wait_time(GameLogic.ROUND_TIME_SEC)
	recap_timer.set_wait_time(GameLogic.RECAP_TIME_SEC)


func _start_server():
	game_logic = GameLogic.new()
	game_logic.set_server(self)
	game_data = game_logic.game_data
	
	print("server mode")

	var result = multiplayer_peer.create_server(port,"*")
	if result != OK:
		print("Failed to start WebSocket server: ", result)
	else:
		print("WebSocket server running on port ", port)
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer.peer_connected.connect(_on_client_connected)
		multiplayer.peer_disconnected.connect(_on_client_disconnected)

func _match_disconnected_name(connected_name: String) -> int:
	for d_id in disconnected_ids:
		if game_data["player_id_name"][d_id] == connected_name:
			disconnected_ids.erase(d_id)
			return d_id
	return 0

func _on_client_connected(id):
	if game_started:
		if disconnected_ids.size() > 0:
			rpc_id(id, "show_reconnect")
		else:
			rpc_id(id, "already_start")
	else:
		print("Client connected: ", id)
		rpc_id(id, "join_lobby")
		game_data.init_player(id)
		set_player_name({"my_net_id": id, "new_name": str(id)})
		check_start_game_button()

func _on_client_disconnected(id):
	print("Client disconnected: ", id)
	if game_started:
		disconnected_ids.append(id)
		var names = []
		for d_id in disconnected_ids:
			names.append(game_data["player_id_name"][d_id])
		rpc_all_clients("disconnect_pause", [names], disconnected_ids)
		game_paused = true
	else:
		game_data.remove_player(id)
		rpc_all_clients("update_player_name", [game_data.player_id_name.values()], [])
		check_start_game_button()

func rpc_all_clients(method_name: String, args=[], except_ids=[]):
	var rpc_args = []
	for other_id in game_data.get_ids():
		if not other_id in except_ids:
			rpc_args = [other_id, method_name]
			rpc_args.append_array(args)
			callv('rpc_id', rpc_args)

func check_start_game_button():
	if game_data.player_id_name.size() >= 4:
		rpc_all_clients("update_start_game_button", [true])
	else:
		rpc_all_clients("update_start_game_button", [false])

func _on_last_cut_timer_timeout():
	if not game_started:
		return
	game_logic.next_round()
	# start recap timer
	rpc_all_clients("show_recap", [game_data.get_data_dict()])
	$RecapTimer.start()

func _on_recap_timer_timeout():
	rpc_all_clients("next_round", [game_data.get_data_dict()])
	round_timer.start()

func _on_bomb_delay_timer_timeout():
	game_started = false
	round_timer.stop()
	for client_id in game_data.get_ids():
		if game_data["player_id_role"][client_id] == GameLogic.ROLE_GOOD:
			rpc_id(client_id, "bomb_explode_client", game_data.get_data_dict(), false)
		else:
			rpc_id(client_id, "bomb_explode_client", game_data.get_data_dict(), true)

func bomb_explodes():
	delay_timer.start()

func _on_defuse_delay_timer_timeout():
	game_started = false
	round_timer.stop()
	for client_id in game_data.get_ids():
		if game_data["player_id_role"][client_id] == GameLogic.ROLE_GOOD:
			rpc_id(client_id, "bomb_defused_client", true)
		else:
			rpc_id(client_id, "bomb_defused_client", false)

func bomb_defused():
	defuse_timer.start()

func _on_round_timer_timeout():
	# TODO: clients, who have not cut, cut a random wire from others
	game_logic.timer_timeout_random_cut()
	
	rpc_all_clients("before_recap_delay")

@rpc("any_peer")
func set_player_name(data: Dictionary):
	game_data.player_id_name[data["my_net_id"]] = data["new_name"]
	rpc_all_clients("update_player_name", [game_data.player_id_name.values()])

@rpc("any_peer")
func start_game():
	print("server start game")
	# set server 
	disconnected_ids = []
	game_started = true
	# set game data
	game_logic.start_game()
	# init and deal wire cards to players
	var wires = game_logic.init_wire_pool(game_data.get_ids())
	var dealt_wires = game_logic.deal_wire(game_data.get_ids(), wires, game_data.current_round)
	game_data.set_player_wire_boxes(dealt_wires)
	# call client start game
	rpc_all_clients("client_start_game", [game_data.get_data_dict()])
	round_timer.start()

@rpc("any_peer")
func declare_defuse_change(defuse_num: int, client_id: int):
	game_data["player_defuse_claim"][client_id] = defuse_num
	rpc_all_clients("update_defuse_claim", [client_id, defuse_num])

@rpc("any_peer")
func have_bomb_pressed(client_id: int):
	var have_bomb = game_data["player_have_bomb_claim"][client_id]
	if have_bomb:
		game_data["player_have_bomb_claim"][client_id] = false
	else:
		game_data["player_have_bomb_claim"][client_id] = true
	rpc_all_clients("update_bomb_claim", [client_id, game_data["player_have_bomb_claim"][client_id]])

@rpc("any_peer")
func request_wire_box(my_id: int, their_id: int):
	#func show_wire_box(their_id: int, their_name: String, their_wire_box: Dictionary, i_finished_cut: bool):
	rpc_id(my_id, "show_wire_box",
	their_id,
	game_data["player_id_name"][their_id],
	game_data["player_wire_boxes"][their_id],
	game_data["player_finished_cut"][my_id])

@rpc("any_peer")
func cut_wire(cutter_id: int, being_cut_id:int, wire_id: int):
	#game_data["player_finished_cut"][cutter_id] = true
	var wire = game_data["player_wire_boxes"][being_cut_id][wire_id]
	#game_data["player_wire_boxes"][being_cut_id][wire_id]["is_cut"] = true
	
	var wire_result = game_logic.cut_wire_logic(cutter_id, being_cut_id, wire_id)
	#game_logic.update_cut_history(cutter_id, being_cut_id, wire["type"])
	rpc_all_clients("update_history", [game_data.history])
	# update
	rpc_all_clients("update_cut_wire", [cutter_id, being_cut_id, wire_id, game_data["remaining_defuse_wire"]])
	rpc_id(being_cut_id, "update_my_wire_cut", wire["type"])
	if wire_result == GameLogic.BOMB_EXPLODES: # if bomb explodes
		bomb_explodes()
	elif wire_result == GameLogic.BOMB_DEFUSED: # if bomb defused
		bomb_defused()
	else:
		# check if all players have finished cut
		var check_result = game_logic.check_next_round()
		if check_result == GameLogic.NEXT_ROUND:
			last_cut_timer.start()
			rpc_all_clients("before_recap_delay")
		elif check_result == GameLogic.BOMB_DEFUSED:
			bomb_defused()
		elif check_result == GameLogic.BOMB_EXPLODES:
			bomb_explodes()

			#print(game_data["history"])
			#print(game_data.get_uncut_wires())
			#if game_data.current_round == 1:
				## ran out of round, so bomb explodes
				#bomb_explodes()
			#else:
				#last_cut_timer.start()
				#rpc_all_clients("before_recap_delay")



@rpc("any_peer")
func restart_game():
	start_game()

@rpc("any_peer")
func request_reconnect(id: int, p_name: String):
	var old_id = _match_disconnected_name(p_name)
	if old_id == 0:
		return
	game_data.init_player(id)
			#var old_id = disconnected_ids.pop_front()
	game_data.replace_player(old_id, id)
	rpc_id(id, "reconnect_game", game_data.get_data_dict())
	rpc_all_clients("update_reconnect_player", [old_id, id], [id])
	if disconnected_ids.size() == 0:
		rpc_all_clients("resume_game")
		game_paused = false
	else:
		rpc_id(id, "disconnect_pause", [""])





# implemented in client
@rpc
func before_recap_delay():
	pass

@rpc
func update_player_name(_data: Array):
	pass

@rpc
func update_start_game_button(_is_vis: bool):
	pass

@rpc
func client_start_game():
	pass

@rpc
func already_start():
	pass

@rpc
func join_lobby():
	pass

@rpc
func reconnect_game(_game_data: Dictionary):
	pass

@rpc
func disconnect_pause(_names: Array):
	pass

@rpc
func resume_game():
	pass

@rpc
func update_reconnect_player(_old_id: int, _new_id: int):
	pass

@rpc
func update_defuse_claim(_value: int, _client_id:int):
	pass

@rpc
func update_bomb_claim(_client_id: int, _has_bomb: bool):
	pass

@rpc
func show_wire_box(_their_id: int, _their_name: String, _their_wire_box: Dictionary, _i_finished_cut: bool):
	pass

@rpc
func update_cut_wire(_cutter_id: int, _client_id: int, _wire_id: int, _remain_defuse: int):
	pass

@rpc
func update_my_wire_cut(_wire_type: String):
	pass

@rpc
func next_round(_game_data: Dictionary):
	pass

@rpc
func bomb_explode_client(_game_data: Dictionary, _is_winner: bool):
	pass

@rpc
func bomb_defused_client(_game_data: Dictionary, _is_winner: bool):
	pass

@rpc
func update_history(_history: Dictionary):
	pass

@rpc
func show_recap(_game_data: Dictionary):
	pass

@rpc
func show_reconnect():
	pass
