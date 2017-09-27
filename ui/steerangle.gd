extends Node2D

var angle = 0 # vehicle will pass actual wheel angle to this variable
var max_angle = 80
var text = null
var wheel_l = null
var wheel_r = null
var bar = null

func _ready():
	set_fixed_process(true)
	text = get_node("Text")
	wheel_l = get_node("WheelL")
	wheel_r = get_node("WheelR")
	# Align bar to bottom center
	var bar = get_node("Bar")
	var window = Vector2(OS.get_window_size().width/2, OS.get_window_size().height)
	var offset = Vector2(0, bar.get_texture().get_height()/2 + 10)
	set_global_pos(window - offset)

func _fixed_process(delta):
	var rotation = angle * -max_angle
	wheel_l.set_rotd(rotation)
	wheel_r.set_rotd(rotation)
	text.set_text(str("%.2f" % angle))
