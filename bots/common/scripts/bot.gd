extends VehicleBody


export(NodePath) var primary_weapon
export(int) var max_speed := 50
export(int) var acceleration_factor := 15
export(bool) var ai_controlled := false

var enemy: Spatial
var prev_d: float

onready var _primary_weapon = get_node_or_null(primary_weapon)
onready var _left_wheels := [$WheelFrontLeft, $WheelRearLeft]
onready var _right_wheels := [$WheelFrontRight, $WheelRearRight]


func _process(delta):
	if Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		get_tree().reload_current_scene()
	
	if Input.is_joy_button_pressed(0, JOY_XBOX_X):
		_right_wheels = []
		if is_instance_valid($WheelRearRight):
			$WheelRearRight.queue_free()
		if is_instance_valid($WheelFrontRight):
			$WheelFrontRight.queue_free()


func _physics_process(delta):
	if ai_controlled:
		_ai_physics_process(delta)
	else:
		_human_physics_process(delta)


func _ai_physics_process(delta):
	# Turreting process.
	var fA = global_transform.basis.z
	var AE = global_transform.origin.direction_to(enemy.global_transform.origin)
	var d = AE.dot(fA)
	# When d == 1 we are facing the enemy. So toggle sticks to make this 1.
	print("d: ", d, " AE.z: ", AE.z)
	if d < 0.99:
		# Not facing
		var rate = 1 - log(abs(d))
		if AE.z > 0:
			# Turn right
			_accelerate(delta, -1 * rate, 1 * rate)
		else:
			# Turn left
			_accelerate(delta, 1 * rate, -1 * rate)
		
		prev_d = d


func _human_physics_process(delta):
	# Handle steering. For now just use tank steering.
	# Left stick controls left wheels.
	# Right stick controls right wheels.
	var left_acceleration = Input.get_joy_axis(0, JOY_AXIS_1)
	var right_acceleration = Input.get_joy_axis(0, JOY_AXIS_4)
	
	_accelerate(delta, left_acceleration, right_acceleration)


func _accelerate(delta, left_acceleration, right_acceleration):
	for wheel in _left_wheels:
		if left_acceleration == 0 and wheel.engine_force > 0:
			wheel.engine_force = 0
			wheel.brake = max_speed
		else:
			wheel.engine_force = max_speed * -left_acceleration
	
	for wheel in _right_wheels:
		if right_acceleration == 0 and wheel.engine_force > 0:
			wheel.brake = max_speed
		else:
			wheel.engine_force = max_speed * -right_acceleration
			
