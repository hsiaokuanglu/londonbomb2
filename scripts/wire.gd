extends Area2D

var cuttable:= true
var mouse_down := false
var wire_type:= ""
var wire_id: int
var is_cut := false
var variation = 1
signal wire_cut(wire_data: Dictionary)


func _on_wire_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if mouse_down and cuttable:
		is_cut = true
		play_cut()
		cuttable = false
		wire_cut.emit({
			"type": wire_type,
			"id": wire_id,
			"is_cut": is_cut,
			"variation": variation})

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			mouse_down = true
		else:
			mouse_down = false

func set_wire_uncut_revealed():
	if is_cut:
		_set_cut_frame()
	else:
		if wire_type == "defuse":
			$Sprite.play("defuse_wire")
		elif wire_type == "safe":
			var x = str("safe_wire", str(variation))
			$Sprite.play(x)
		elif wire_type == "bomb":
			$Sprite.play("bomb")
		else:
			$Sprite.play("default")

func set_wire_uncut_hidden():
	$Sprite.play(str("safe_wire", str(variation)))

func _set_cut_frame():
	if wire_type == "defuse":
		$Sprite.set_animation("defuse_wire_cut")
		$Sprite.set_frame(3)
	elif wire_type == "safe":
		$Sprite.play(str("safe_wire_cut", str(variation)))
		$Sprite.set_frame(3)
	elif wire_type == "bomb":
		$Sprite.play("bomb_cut")
		$Sprite.set_frame(3)
	else:
		$Sprite.set_frame(0)

func play_cut():
	if wire_type == "defuse":
		$Sprite.play("defuse_wire_cut")
	elif wire_type == "safe":

		$Sprite.play(str("safe_wire_cut", str(variation)))
	elif wire_type == "bomb":
		$Sprite.play("bomb_cut")
	else:
		$Sprite.play(str("safe_wire_cut", str(variation)))
