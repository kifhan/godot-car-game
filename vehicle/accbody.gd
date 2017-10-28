extends KinematicBody

var vel = Vector3()
const ACCEL= 2
const MAX_SPEED = 200

func _fixed_process(delta):
	var car = get_node("Car")
	var dir = car.get_linear_velocity()
	dir = dir.rotated(Vector3(0,0,1), car.get_steering())
	
	dir.y = 0
	dir = dir.normalized()
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir*MAX_SPEED
	var accel = pow(car.speed, 4) / 8000000
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	
	vel.x = hvel.x
	vel.z = hvel.z
	
	if (car.speed > 15) :
		move(vel*delta)
		vel = vel * 0.97
	else :
		vel = vel * 0
	
func _ready():
	set_fixed_process(true)
