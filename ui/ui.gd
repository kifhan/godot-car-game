extends Node

var debug_text

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	debug_text = get_node("DebugText")
	
func _input(event):
	pass

func _fixed_process(delta):
	debug_text.set_text(str(
						"FPS: ", OS.get_frames_per_second(), "\n",
						"Memory (D): ", OS.get_dynamic_memory_usage(), "\n",
						"Memory (S): ", OS.get_static_memory_usage(), "/", OS.get_static_memory_peak_usage()
						))