extends PanelContainer

@onready
var tree = $VBoxContainer/ScrollContainer/PanelContainer/Tree

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = tree.create_item()
	for i in range(4, 0, -1):
		var n_1 = tree.create_item(root)
		n_1.set_text(0, str(i))
		for j in range(2):
			var n2 = tree.create_item(n_1)
			n2.set_text(0, str(j))

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



func _on_show_button_pressed() -> void:
	var container =$VBoxContainer/ScrollContainer
	if container.is_visible():
		container.hide()
	else:
		container.show()
