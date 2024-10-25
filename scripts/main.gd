extends Node

var debug = true

func _ready():
	# get arg
	var args = Array(OS.get_cmdline_args())
	# if server
	if DisplayServer.get_name() == "headless" or args.has("server"):
		var server = preload("res://scenes/server.tscn").instantiate()
		server.set_name("Client")
		add_child(server)
		
		# client for rpc
		#var client = preload("res://scenes/client.tscn").instantiate()
		#add_child(client)

		# set window position
		get_window().set_position(Vector2i(0, 0))
	else: # if client
		var client = preload("res://scenes/client.tscn").instantiate()
		add_child(client)

		# easier debug
		if debug:
			# window position
			var window_offset = 1
			if args.size() > 1:
				window_offset = int(args[1])
			get_window().set_initial_position(Window.WINDOW_INITIAL_POSITION_ABSOLUTE)
			get_window().set_position(Vector2i(450*window_offset, 0))
			if args.size() > 2:
				var p_name = args[2]
				client.dev_join(p_name)
