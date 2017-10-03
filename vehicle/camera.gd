
extends Camera

# Camera modes
const CAMERA_FOLLOW = 1
const CAMERA_TOPDOWN = 2
var camera_mode

# Camera following params
var collision_exception = []
var min_distance = 2.0
var max_distance = 8.0
var angle_v_adjust = 0.0
var autoturn_ray_aperture = 30
var autoturn_speed = 60
var max_height = 3.0
var min_height = 1.0

# Camera topdown params
var topdown_distance = 70

# Initial camera target for topdown
var origin
var target_orig

func _ready():
	# Set default camera mode
	camera_mode = CAMERA_FOLLOW
	#Set origin
	origin = get_global_transform().origin
	target_orig = get_parent().get_global_transform().origin
	# Find collision exceptions for ray
	var node = self
	while(node):
		if (node extends RigidBody):
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
			
	set_process_input(true)
	set_fixed_process(true)
	
	# This detaches the camera transform from the parent spatial node
	set_as_toplevel(true)

func _input(event):
	if (event.is_action_pressed("key_camera")):
		if (camera_mode == CAMERA_TOPDOWN):
			camera_mode = CAMERA_FOLLOW
		else:
			camera_mode = CAMERA_TOPDOWN

func _fixed_process(dt):
	var target = get_parent().get_global_transform().origin
	
	# Top-down camera
	if (camera_mode == CAMERA_TOPDOWN):
		# follow the player
		var delta = target - target_orig
		# Mmove up and rotate to look down
		set_translation(origin + Vector3(0, topdown_distance, 0) + delta)
		set_rotation_deg(Vector3(-90, 0, 180))
	# Follow camera (default)
	else:
		var pos = get_global_transform().origin
		var up = Vector3(0, 1, 0)
		
		var delta = pos - target
		
		# Regular delta follow
		
		# Check ranges
		if (delta.length() < min_distance):
			delta = delta.normalized()*min_distance
		elif (delta.length() > max_distance):
			delta = delta.normalized()*max_distance
		
		# Check upper and lower height
		if ( delta.y > max_height):
			delta.y = max_height
		if ( delta.y < min_height):
			delta.y = min_height
		
		pos = target + delta
		
		look_at_from_pos(pos, target, up)
		
		# Turn a little up or down
		var t = get_transform()
		t.basis = Matrix3(t.basis[0], deg2rad(angle_v_adjust))*t.basis
		set_transform(t)
