extends Node2D

var speed = 0 # vehicle will pass actual speed to this variable here
var min_speed = 0
var max_speed = 220
var min_rot = 135
var max_rot = -135
var arrow = null
var text = null

func _ready():
	set_fixed_process(true)
	arrow = get_node("Arrow")
	text = get_node("Text")
	# Align speedometer to bottom right
	var ring = get_node("Ring")
	var window = Vector2(OS.get_window_size().width, OS.get_window_size().height)
	var offset = Vector2(ring.get_texture().get_width()/2, ring.get_texture().get_height()/2)
	set_global_pos(window - offset)

func _fixed_process(delta):
	arrow.set_rotd(speed_to_rot(speed))
	text.set_text(str(int(speed), " km/h"))

func speed_to_rot(speed):
	var total_rot = abs(min_rot) + abs(max_rot)
	speed = min(speed, max_speed)
	speed = max(speed, min_speed)
	var rot_per_speed = float(total_rot) / float(max_speed)
	var speed_rot = min_rot - (speed * rot_per_speed)
	return speed_rot