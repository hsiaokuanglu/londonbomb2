extends Panel

@export
var tree: Tree

#func _ready():
	#set_history({ 4: { "956969357": { "cut_wire": { "being_cut_name": "1947937223", "wire_type": "safe" } }, "675004934": { "cut_wire": { "being_cut_name": "1793898394", "wire_type": "safe" } }, "1947937223": { "cut_wire": { "being_cut_name": "1793898394", "wire_type": "safe" } }, "1793898394": { "cut_wire": { "being_cut_name": "1947937223", "wire_type": "safe" } } }, 3: {  }, 2: {  }, 1: {  } })

func set_history(history: Dictionary):
	#reset
	tree.clear()
	var root = tree.create_item()

	for round_n in history.keys():
		var round_tree = tree.create_item(root)
		round_tree.set_text(0, str("round ", str(round_n)))
		for p_name in history[round_n].keys():
			var being_cut_name = history[round_n][p_name]["cut_wire"]["being_cut_name"]
			var wire_type = history[round_n][p_name]["cut_wire"]["wire_type"]
			var cut_action_tree = tree.create_item(round_tree)
			var cut_str = str(p_name, " cut ", being_cut_name, "\'s wires: ", wire_type)
			cut_action_tree.set_text(0, cut_str)
	
