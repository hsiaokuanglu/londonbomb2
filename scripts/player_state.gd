class_name SavedPlayerState

var id: int
var player_name: String
var role: String
var my_wires
var finished_cut: bool
var claimed_defuse_num: int
var i_have_bomb: bool
var player_id_names: Dictionary


func _ready():
	id = 0
	player_name = ""
	role = ""
	player_id_names = Dictionary()
	my_wires = []
	finished_cut = false
	claimed_defuse_num = 0
	i_have_bomb = false
	
func set_state(_id, _player_name, _role, _my_wires, _finished_cut, _claimed_defuse_num, _i_have_bomb, _player_id_names):
	id = _id
	player_name = _player_name
	role = _role
	my_wires = _my_wires
	finished_cut = _finished_cut
	claimed_defuse_num = _claimed_defuse_num
	i_have_bomb = _i_have_bomb
	player_id_names = _player_id_names
	
func set_state_dict(state_dict):
	id = state_dict["id"]
	player_name = state_dict["player_name"]
	role = state_dict["role"]
	my_wires = state_dict["my_wires"]
	finished_cut = state_dict["finished_cut"]
	claimed_defuse_num = state_dict["claimed_defuse_num"]
	i_have_bomb = state_dict["i_have_bomb"]
	player_id_names = state_dict["player_id_names"]

func get_state():
	return Dictionary({
		"id": id,
		"player_name": player_name,
		"role": role,
		"my_wires": my_wires,
		"finished_cut": finished_cut,
		"claimed_defuse_num": claimed_defuse_num,
		"i_have_bomb": i_have_bomb,
		"player_id_names": player_id_names})
