extends VBoxContainer

var current_round: int
var is_recap = false

signal round_timer_timeout

#@export
#var recap_timer: Timer
@export
var round_timer: Timer

func zero_timer_bar():
	$RoundTimerBar.set_value_no_signal(0)
	round_timer.stop()

func set_round_number(r_num: int):
	current_round = r_num
	$HBoxContainer/Number.text = str(str(r_num), "")
	#$round_timer.start()

func start_round_countdown(time_sec: float):
	$RoundTimerBar.set_max(time_sec)
	round_timer.start(time_sec)

#func start_recap():
	#recap_timer.start()
	#is_recap = true

func _process(_delta: float) -> void:
	$HBoxContainer/Decimal.set_text(str(":", str($RoundTimer.get_time_left()).pad_decimals(2)))
	$RoundTimerBar.set_value_no_signal($RoundTimer.get_time_left())
	#if is_recap:
		#var round_time_str = str(":0", str(recap_timer.get_time_left()).pad_decimals(2))
		#$HBoxContainer/Decimal.set_text(round_time_str)
	#else:
		#$HBoxContainer/Decimal.set_text(str(":", str($RoundTimer.get_time_left()).pad_decimals(2)))
		#$RoundTimerBar.set_value_no_signal($RoundTimer.get_time_left())

#func _on_recap_timer_timeout() -> void:
	#is_recap = false

func _dev():
	#current_round = 4
	#start_recap()
	set_round_number(4)
	zero_timer_bar()
	start_round_countdown(10)

#func _ready():
	#_dev()


func _on_round_timer_timeout() -> void:
	round_timer_timeout.emit()
