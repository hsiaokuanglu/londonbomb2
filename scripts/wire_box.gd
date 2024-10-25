extends Panel

var wire_box_height = 200
var wire_gap = 100
var cur_player_id: int

var wire_scenes = Dictionary()

signal wire_cut(wire_data: Dictionary)
signal exit_box

func set_wires(player_id: int, p_name: String, wires: Dictionary, already_cut: bool):
	#$PlayerName.set_position(Vector2(-200, -340))
	_clear_wire_scenes()
	cur_player_id = player_id
	$PlayerName.text = p_name

	var pos_x = 0
	var pos_y = - wire_box_height
	for i in range(wires.keys().size()):
		var wire_scene = preload("res://scenes/wire.tscn").instantiate()
		wire_scene.wire_type = wires[i]["type"]
		wire_scene.wire_id = i
		wire_scene.position = Vector2(pos_x, pos_y)
		wire_scene.variation = wires[i]["variation"]
		wire_scene.connect("wire_cut", _on_wire_cut)
		wire_scenes[i] = wire_scene

		if already_cut:
			wire_scene.cuttable = false
		if wires[i]["is_cut"]:
			wire_scene._set_cut_frame()
			wire_scene.is_cut = wires[i]["is_cut"]
			wire_scene.cuttable = false
		else:
			wire_scene.set_wire_uncut_hidden()

		pos_y += wire_gap
		$Wires.add_child(wire_scene)

func set_my_box(player_id, wires):
	#$Sprite2D.hide()
	$ExitButton.hide()
	$Frame.hide()
	wire_box_height = 50
	wire_gap = 25
	$Sprite2D.play("my_box")
	var wire_index_shuffle = []
	for i in range(wires.keys().size()):
		wire_index_shuffle.append(i)
	wire_index_shuffle.shuffle()
	var shuffled_wires = Dictionary()
	for i in range(wire_index_shuffle.size()):
		shuffled_wires[wire_index_shuffle[i]] = wires[i]

	#wires.shuffle()
	set_wires(player_id, "My Wires", shuffled_wires, true)
	#$PlayerName.text = "My Wires"

	$PlayerName.set_position(Vector2(-200, -150))
	
	for wire in wire_scenes.values():
		#wire.cuttable = false
		#print(wire.wire_type)
		wire.set_wire_uncut_revealed()
		wire.set_scale(Vector2(0.7, 0.7))

func _clear_wire_scenes():
	wire_scenes.clear()
	for ch in $Wires.get_children():
		$Wires.remove_child(ch)
		ch.queue_free()

func init_my_box(is_mine: bool):
	if is_mine:
		$Sprite2D.play("my_box")
		$ExitButton.hide()
		$PlayerName.text = "My Wires"
		$PlayerName.set_position(Vector2(-200, -155))
	else:
		$Sprite2D.play("others_box")
		$PlayerName.set_position(Vector2(-200, -340))

func update_cut_wire(wire_id: int):
	wire_scenes[wire_id].play_cut()
	wire_scenes[wire_id].cuttable = false

func update_cut_my_wire(wire_type: String):
	for wire in wire_scenes.values():
		if wire.wire_type == wire_type and not wire.is_cut:
			wire.play_cut()
			wire.is_cut = true
			return

#{"type": wire_type, "id": wire_id, "is_cut": bool}
func _on_wire_cut(wire_data: Dictionary):
	wire_cut.emit(wire_data)
	for wire in wire_scenes.values():
		wire.cuttable = false

func set_player_card_wire(wires: Dictionary):
	$Frame.hide()
	$ExitButton.hide()
	$Sprite2D.set_scale(Vector2(0.45, 0.45))
	wire_box_height = 25
	wire_gap = 13
	$Sprite2D.play("my_box")
	set_wires(cur_player_id, "", wires, true)
	for wire_s in wire_scenes.values():
		wire_s.set_scale(Vector2(0.4, 0.8))

func _on_exit_button_pressed() -> void:
	hide()
	exit_box.emit()


func _on_button_pressed() -> void:
	set_wires(12345, 
	"",
	{
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
	},
	false
	)
