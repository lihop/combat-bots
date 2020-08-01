extends Spatial


const RESET_FORCE := -1.5
const FIRE_FORCE := 1000


var _hammer_fired := false


func _physics_process(delta):
	if Input.is_action_just_pressed("bot_weapon_primary"):
		if _hammer_fired:
			$HingeJoint.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, RESET_FORCE)
			_hammer_fired = false
		else:
			$HingeJoint.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, FIRE_FORCE)
			_hammer_fired = true
