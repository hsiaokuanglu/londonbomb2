extends Node

var multiplayer_peer = WebSocketMultiplayerPeer.new()
var debug = true
var url = "wss://luraykuang1998.online:443"
var url_dev = "ws://localhost:8765"
#
var my_net_id: int
var player_cards: Dictionary
var finished_cut: bool
#
@export
var pause_panel: PanelContainer
@export
var claim_ui: Control
@export
var my_wire_box: Panel
@export
var their_wire_box_ui: Panel
@export
var in_game_ui: Panel
@export
var role_texture: TextureRect
@export
var round_number: VBoxContainer
@export
var remaining_defuse_label: Label
@export
var declare_window: PanelContainer
@export
var player_card_grid_ui: GridContainer
@export
var explode_panel: Panel
@export
var ending_panel: Panel
@export
var round_recap: Panel

@onready
var network_ui = $NetworkContainer

func _ready() -> void:
	$NetworkContainer.show()
	in_game_ui.hide()
	their_wire_box_ui.hide()
	my_wire_box.init_my_box(true)
	their_wire_box_ui.init_my_box(false)

# for easier debug
func dev_join(_p_name: String):
	network_ui._on_join_pressed()
	#network_ui.dev_set_name(p_name)

func _on_connection_established():
	my_net_id = multiplayer.get_unique_id()
	print("Connected to server")
	network_ui.set_connection_status_str("Connected to server")
	var temp_name = network_ui._get_entered_name()
	if temp_name == "":
		temp_name = str(my_net_id)
	_on_network_container_set_player_name(temp_name)

func _on_connection_error():
	print("Connection error")
	network_ui.set_connection_status_str("Connection error")

func set_role_icon(role: String):
	if role == GameLogic.ROLE_GOOD:
		role_texture.set_texture(load("res://art/role_pic/good_guy.png"))
		$InGameUI/RoleCon/RoleLabel.text = GameLogic.ROLE_GOOD
	elif role == GameLogic.ROLE_BAD:
		role_texture.set_texture(load("res://art/role_pic/bad_guy.png"))
		$InGameUI/RoleCon/RoleLabel.text = GameLogic.ROLE_BAD

func set_round_number(round_n: int):
	round_number.set_round_number(round_n)

func set_remaining_defuse_number(defuse_n: int):
	remaining_defuse_label.text = str(defuse_n)

# set player grid
func _set_player_grid(game_data: Dictionary):
	player_cards = Dictionary()
	for their_id in game_data["player_id_name"].keys():
		var player_card = preload("res://scenes/player_card.tscn").instantiate()
		player_card.set_multiplayer_authority(my_net_id)
		player_card.set_id_name(their_id, game_data["player_id_name"][their_id])
		# set finished cut
		player_card.set_finished_cut(game_data["player_finished_cut"][their_id])
		# connect check wire signal
		player_card.check_wire.connect(_on_check_wire_pressed)
		player_cards[their_id] = player_card
		# set wire box
		player_card.set_player_card_wire(game_data["player_wire_boxes"][their_id])
		# disable check wire if the player card is myself
		if their_id == my_net_id:
			player_card.disable_check_button()
		player_card_grid_ui.add_child(player_card)

func clear_player_card():
	player_cards.clear()
	for ch in player_card_grid_ui.get_children():
		player_card_grid_ui.remove_child(ch)
		ch.queue_free()

func show_in_game():
	network_ui.hide()
	in_game_ui.show()


# callback events

# send to server
func _on_network_container_set_player_name(p_name: String) -> void:
	rpc_id(1, "set_player_name", 
		Dictionary({"my_net_id": my_net_id, "new_name": p_name}))

func _on_network_container_start_game() -> void:
	rpc_id(1, "start_game")

func _on_check_wire_pressed(their_id: int):
	rpc_id(1, "request_wire_box", my_net_id, their_id)

func _on_explode_panel_animation_finished() -> void:
	explode_panel.hide()
	ending_panel.show()

func _on_join_game() -> void:
	var err
	if debug == true:
		err = multiplayer_peer.create_client(url_dev) 
	else:
		err = multiplayer_peer.create_client(url, TLSOptions.client())
	if err == OK:
		print("Connecting to WebSocket server...")
		multiplayer.multiplayer_peer = multiplayer_peer
		my_net_id = multiplayer.get_unique_id()
		network_ui.set_multiplayer_authority(my_net_id)
		multiplayer.connected_to_server.connect(_on_connection_established)	
		multiplayer.connection_failed.connect(_on_connection_error)	

func _on_their_wire_box_wire_cut(wire_data: Dictionary) -> void:
	rpc_id(1, "cut_wire",
		my_net_id,
		their_wire_box_ui.cur_player_id,
		wire_data["id"])

func _on_ending_panel_restart() -> void:
	ending_panel.hide()
	rpc_id(1, "restart_game")

func _on_their_wire_box_exit_box() -> void:
	player_card_grid_ui.show()

func _on_claim_ui_declare_pressed() -> void:
	declare_window.show()

func _on_declare_window_spinbox_value_change(value: int) -> void:
	rpc_id(1, "declare_defuse_change", value, my_net_id)

func _on_claim_ui_have_bomb_presssed() -> void:
	rpc_id(1, "have_bomb_pressed", my_net_id)

func _on_network_container_on_reconnect(p_name: String) -> void:
	var my_id = multiplayer.get_unique_id()
	rpc_id(1,
		"request_reconnect",
		my_id,
		p_name)

@rpc
func round_timer_timeout(game_data: Dictionary):
	pass

@rpc
func bomb_defused_client(is_winner: bool):
	in_game_ui.hide()
	ending_panel.set_win_or_lose(is_winner)
	ending_panel.set_result(GameLogic.BOMB_DEFUSED)
	ending_panel.show()

@rpc
func bomb_explode_client(is_winner: bool):
	in_game_ui.hide()
	ending_panel.set_win_or_lose(is_winner)
	ending_panel.set_result(GameLogic.BOMB_EXPLODES)
	#
	explode_panel.play_animation()

@rpc
func show_recap(game_data: Dictionary):
	round_recap.show()
	round_recap.set_history(game_data["history"])
	round_recap.start_timer_bar()
	round_number.start_recap()

@rpc("authority")
func client_start_game(game_data: Dictionary):
	clear_player_card()
	in_game_ui.show()
	explode_panel.hide()
	ending_panel.hide()
	player_card_grid_ui.show()
	their_wire_box_ui.hide()
	# reset history
	update_history(game_data["history"])
	# set role
	set_role_icon(game_data["player_id_role"][my_net_id])
	# set round number
	set_round_number(game_data["current_round"])
	# set remaining defuse wire count
	set_remaining_defuse_number(game_data["remaining_defuse_wire"])
	# set wire box
	my_wire_box.set_my_box(my_net_id, game_data["player_wire_boxes"][my_net_id])
	# player card grid
	_set_player_grid(game_data)
	# set defuse claim
	for id in game_data["player_defuse_claim"].keys():
		update_defuse_claim(id, game_data["player_defuse_claim"][id])
	# set declare window spinbox number
	declare_window.reconnect_set_defuse_num(game_data["player_defuse_claim"][my_net_id])
	# set have bomb claim
	for id in game_data["player_have_bomb_claim"].keys():
		update_bomb_claim(id, game_data["player_have_bomb_claim"][id])

	show_in_game()
	round_number.start_round_countdown()

@rpc
func update_history(history: Dictionary):
	$InGameUI/History.set_history(history)

@rpc
func update_cut_wire(cutter_id: int, client_id: int, wire_id: int, remain_defuse: int):
	player_cards[client_id].cut_player_card_wire(wire_id)
	player_cards[cutter_id].set_finished_cut(true)
	remaining_defuse_label.text = str(remain_defuse)
	if their_wire_box_ui.is_visible():
		if client_id == their_wire_box_ui.cur_player_id:
			their_wire_box_ui.update_cut_wire(wire_id)

@rpc
func update_my_wire_cut(wire_type: String):
	my_wire_box.update_cut_my_wire(wire_type)

@rpc
func show_wire_box(their_id: int, their_name: String, their_wire_box: Dictionary, i_finished_cut: bool):
	# set_wires(_player_id: int, p_name: String, wires: Dictionary, already_cut: bool):
	their_wire_box_ui.set_wires(their_id, their_name, their_wire_box, i_finished_cut)
	player_card_grid_ui.hide()
	their_wire_box_ui.show()

@rpc
func next_round(game_data: Dictionary):
	round_number.start_round_countdown()
	round_recap.hide()
	#_round_recap_timer(game_data)
	# reset finished cut
	for p_card in player_cards.values():
		p_card.set_finished_cut(false)
		p_card.set_have_bomb_claim(false)
		# reset player_card wire box
		p_card.set_player_card_wire(game_data["player_wire_boxes"][p_card.client_id])
		#p_card.set_defuse_claim(0)
	declare_window._set_spinbox_value(0)

	their_wire_box_ui.hide()
	player_card_grid_ui.show()
	# update round number
	round_number.set_round_number(game_data["current_round"])
	# set wires
	my_wire_box.set_my_box(my_net_id, game_data["player_wire_boxes"][my_net_id])

@rpc
func disconnect_pause(names: Array):
	pause_panel.show()
	var names_str = ""
	for p_name in names:
		names_str += str(p_name, ", ")
	names_str += "has disconnected. \nWaiting for player to reconnect..."
	$InGameUI/PausePanel/PauseLabel.set_text(names_str)

@rpc
func show_reconnect():
	network_ui.show_reconnect()

@rpc
func join_lobby():
	network_ui.joined_lobby()

@rpc
func update_player_name(p_list: Array):
	network_ui.set_player_list(p_list)

@rpc
func update_start_game_button(is_vis: bool):
	network_ui.set_start_game_button(is_vis)

@rpc
func already_start():
	network_ui.set_connection_status_str("game already started")

@rpc
func reconnect_game(game_data: Dictionary):
	client_start_game(game_data)

@rpc
func update_reconnect_player(old_id: int, new_id: int):
	# replace old id with new id
	player_cards[new_id] = player_cards[old_id]
	player_cards[new_id].client_id = new_id
	player_cards.erase(old_id)

@rpc
func resume_game():
	pause_panel.hide()

@rpc
func update_defuse_claim(client_id:int, defuse_num: int):
	player_cards[client_id].set_defuse_claim(defuse_num)

@rpc
func update_bomb_claim(client_id: int, has_bomb: bool):
	player_cards[client_id].set_have_bomb_claim(has_bomb)









# implemented in server
@rpc
func set_player_name(_data: Dictionary):
	pass

@rpc
func start_game():
	pass

@rpc
func declare_defuse_change(_value: int):
	pass

@rpc
func have_bomb_pressed(_my_net_id: int):
	pass

@rpc
func request_wire_box(_my_id: int, _their_id: int):
	pass

@rpc
func cut_wire(_cutter_id: int, _being_cut_id:int, _wire_id: int):
	pass

@rpc
func restart_game():
	pass

@rpc
func request_reconnect(_id: int, _p_name: String):
	pass
