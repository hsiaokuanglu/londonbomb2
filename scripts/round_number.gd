extends HBoxContainer

var current_round: int
var is_recap = false
@onready
var recap_timer = $RecapTimer

func set_round_number(r_num: int):
	current_round = r_num
	$Number.text = str(str(r_num), "")
	$RoundTimer.start()

func start_recap():
	recap_timer.start()
	is_recap = true

func _process(_delta: float) -> void:
	if is_recap:
		var round_time_str = str(":0", str(recap_timer.get_time_left()).pad_decimals(2))
		$Decimal.set_text(round_time_str)
	else:
		$Decimal.set_text(str(":", str($RoundTimer.get_time_left()).pad_decimals(2)))

func _on_recap_timer_timeout() -> void:
	is_recap = false

func _dev():
	#current_round = 4
	#start_recap()
	set_round_number(4)

#func _ready():
	#_dev()
