extends VehicleBody


export(NodePath) var primary_weapon
export(int) var max_speed := 50
export(int) var acceleration_factor := 15

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
	# Handle steering. For now just use tank steering.
	# Left stick controls left wheels.
	# Right stick controls right wheels.
	var left_acceleration = Input.get_joy_axis(0, JOY_AXIS_1)
	var right_acceleration = Input.get_joy_axis(0, JOY_AXIS_4)
	
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
			
