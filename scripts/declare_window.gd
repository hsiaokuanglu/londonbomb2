extends PanelContainer

var min_val = 0
var max_val = 5
signal spinbox_value_change(value:int)
signal declare_exit_press

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = get_size()
	$Sprite2D.set_position(Vector2(window_size.x / 2, window_size.y /2))
	$Sprite2D.set_scale(Vector2(window_size.x/100, (window_size.y + 50)/100))


func _set_spinbox_max(max_num):
	max_val = max_num

func _set_spinbox_value(value: int):
	$VBoxContainer/HBoxContainer/NumberLabel.set_text(str(value))
	spinbox_value_change.emit(value)
	

func _on_spin_box_value_changed(value: float) -> void:
	spinbox_value_change.emit(value)
	#print(value)

func reconnect_set_defuse_num(value: int):
	$VBoxContainer/HBoxContainer/NumberLabel.set_text(str(value))


func _on_exit_button_pressed() -> void:
	hide()
	declare_exit_press.emit()


func _on_up_button_pressed() -> void:
	var num_str = $VBoxContainer/HBoxContainer/NumberLabel.get_text()
	var num_int = int(num_str)
	num_int += 1
	if num_int > max_val:
		num_int = max_val
	$VBoxContainer/HBoxContainer/NumberLabel.set_text(str(num_int))
	spinbox_value_change.emit(num_int)


func _on_down_button_pressed() -> void:
	var num_str = $VBoxContainer/HBoxContainer/NumberLabel.get_text()
	var num_int = int(num_str)
	num_int -= 1
	if num_int < min_val:
		num_int = min_val
	$VBoxContainer/HBoxContainer/NumberLabel.set_text(str(num_int))
	spinbox_value_change.emit(num_int)
