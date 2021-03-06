extends VehicleBody

# Constants
const WEIGHT = 1450
const FRICTION = 1.0
const ENGINE_FORCE = 3000

const STEER_SPEED = 1
const STEER_LIMIT = 1
const MAX_SPEED = 240 # kph

# Car
var car_name = "Player"
var is_player = true
var initial_pos = null

# Steering
var steer_angle = 0
var steer_target = 0

# Speed
var speed = 0
var speed_mph = 0
var speed_kph = 0

# Lights
var head_light = null
var brake_light = null
var reverse_light = null
var head_light_l = null
var head_light_r = null

var headlight_light_on = true
var headlight_spotlight_on = false

# wheels

var wheel_rl
var wheel_rr

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	set_friction(FRICTION)
	set_mass(WEIGHT)
	head_light = get_node("Body").get_mesh().surface_get_material(10)
	brake_light = get_node("Body").get_mesh().surface_get_material(5)
	reverse_light = get_node("Body").get_mesh().surface_get_material(1)
	head_light_l = get_node("Headlight L")
	head_light_r = get_node("Headlight R")
	set_head_lights(headlight_light_on, headlight_spotlight_on)
	wheel_rl = get_node("Wheel RL")
	wheel_rr = get_node("Wheel RR")
	initial_pos = get_global_transform().origin # used for car resetting
	
func _input(event):
	if event.type == InputEvent.KEY:
		# Reset car
		if (event.is_action_pressed("key_reset")):
			reset_car()
		# Toggle headlights
		if (event.is_action_pressed("key_headlights")):
			set_head_lights(headlight_light_on, !headlight_spotlight_on)

func _fixed_process(delta):

	speed = get_linear_velocity().length()
	speed_kph = speed * 3.6
	speed_mph = speed * 2.237
	
	# var steer_speed_multiplier = 1

	# Update speedometer
	get_node("Speedometer").speed = speed_kph
		
	# Faster acceleration from 0
	var final_engine_force = ENGINE_FORCE
	var final_steer_speed = STEER_SPEED
	if (speed_kph > 180):
		final_engine_force = ENGINE_FORCE*0.25
		final_steer_speed = STEER_SPEED*0.1
	elif (speed_kph > 160):
		final_engine_force = ENGINE_FORCE*0.5
		final_steer_speed = STEER_SPEED*0.25
	elif (speed_kph > 120):
		final_engine_force = ENGINE_FORCE*0.75
		final_steer_speed = STEER_SPEED*0.5
	elif (speed_kph > 60):
		final_engine_force = ENGINE_FORCE
		final_steer_speed = STEER_SPEED*0.75
	elif (speed_kph > 30):
		final_engine_force = ENGINE_FORCE*1.25
		final_steer_speed = STEER_SPEED
	elif (speed_kph > 20):
		final_engine_force = ENGINE_FORCE*1.5
		final_steer_speed = STEER_SPEED*1.1
	elif (speed_kph > 10):
		final_engine_force = ENGINE_FORCE*1.75
		final_steer_speed = STEER_SPEED*1.25
	else:
		final_engine_force = ENGINE_FORCE*1.95
		final_steer_speed = STEER_SPEED*1.5
		
	# Steer
	if (Input.is_action_pressed("ui_left")):
		steer_target = -STEER_LIMIT
		if (get_steering() > 0.2):
			pass
			# print("left but right")
			# steer_speed_multiplier += 4
	elif (Input.is_action_pressed("ui_right")):
		steer_target = STEER_LIMIT
		if (get_steering() < -0.2):
			pass
			# print("right but left")
			# steer_speed_multiplier += 4
	else:
		steer_target = 0
		# faster turning when resetting to straight
		final_steer_speed += 1
		
	# Accelerate
	if (Input.is_action_pressed("ui_up")):
		if (speed_kph < MAX_SPEED):
			set_engine_force(final_engine_force)
		else:
			set_engine_force(0)
	else:
		set_engine_force(0)
		# faster turning without accelerating
		# steer_speed_multiplier += 1.2

	# Brake / Reverse
	var show_reverse_lights = false
	if (Input.is_action_pressed("ui_down")):
		if (speed_kph > 20):
			set_brake(1.0)
			set_engine_force(-ENGINE_FORCE*2) # braking force
			set_brake_lights(true)
		else:
			# Reverse
			set_brake(0.0)
			set_engine_force(-ENGINE_FORCE)
		show_reverse_lights = get_engine_force() < 0 # get_linear_velocity().dot(get_global_transform().xform(Vector3(0, 1.5, 2))-get_global_transform().origin) > 0
	else:
		set_brake_lights(false)
		set_brake(0.0)

	set_reverse_lights(show_reverse_lights)
	
	# Handbrake
	if (Input.is_action_pressed("key_handbrake")):
		set_brake(1.0)
		set_engine_force(0)
		# Increase steering speed
		# steer_speed_multiplier += 1.5
		
	# var steer_speed_multiplier = 0.5 + pow(abs(steer_target - steer_angle), 2) # (1 + pow(abs(steer_angle), 2) * 3)
	final_steer_speed = final_steer_speed*delta
	
	# var friction_slip = STEER_LIMIT - pow(abs(steer_angle), 2)

	# wheel_rl.set_friction_slip(friction_slip)
	# wheel_rr.set_friction_slip(friction_slip)

	if (steer_target < steer_angle):
		steer_angle -= final_steer_speed
		steer_angle = max(steer_target, steer_angle)
	elif (steer_target > steer_angle):
		steer_angle += final_steer_speed
		steer_angle = min(steer_target, steer_angle)
	
	# The further we have to turn wheels, the faster we want it
	# STEER_SPEED *= 1 + pow(abs(steer_angle), 1.5)
				
	set_steering(steer_angle)

	# Update steer angle
	get_node("steerangle").angle = steer_angle


func set_brake_lights(on):
	if (on):
		brake_light.set_parameter(FixedMaterial.PARAM_GLOW, 1.0)
		brake_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(25, 0, 0))
	else:
		brake_light.set_parameter(FixedMaterial.PARAM_GLOW, 0.5)
		brake_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(0.5, 0, 0))

func set_reverse_lights(on):
	if (on):
		reverse_light.set_parameter(FixedMaterial.PARAM_GLOW, 1.0)
		reverse_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(25, 25, 25))
	else:
		reverse_light.set_parameter(FixedMaterial.PARAM_GLOW, 0)
		reverse_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(0.1, 0.1, 0.1))

func set_head_lights(light, spotlight):
	headlight_light_on = light
	headlight_spotlight_on = spotlight
	if (light):
		head_light.set_parameter(FixedMaterial.PARAM_GLOW, 0.75)
		head_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(10, 10, 0))
	else:
		head_light.set_parameter(FixedMaterial.PARAM_GLOW, 0)
		head_light.set_parameter(FixedMaterial.PARAM_EMISSION, Color(0.2, 0.2, 0))

	if (spotlight):
		head_light_l.set_enabled(true)
		head_light_r.set_enabled(true)
	else:
		head_light_l.set_enabled(false)
		head_light_r.set_enabled(false)

func reset_car():
	set_brake(0.0)
	set_engine_force(0.0)
	set_steering(0.0)
	set_translation(initial_pos)
	var reset_rot = Vector3(0, 0, 0)
	set_rotation_deg(reset_rot)
