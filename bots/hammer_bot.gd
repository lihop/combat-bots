extends Spatial


export(bool) var ai_controlled := false
export(NodePath) var enemy: NodePath

const RESET_FORCE := -1.5
const FIRE_FORCE := 1000


var _hammer_fired := false


func _ready():
	if ai_controlled:
		$Chassis.ai_controlled = true
		var e = get_node(enemy)
		$Chassis.enemy = e.get_node("Chassis")
	else:
		$Chassis.ai_controlled = false


func _physics_process(delta):
	if ai_controlled:
		return
	
	if Input.is_action_just_pressed("bot_weapon_primary"):
		if _hammer_fired:
			$HingeJoint.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, RESET_FORCE)
			_hammer_fired = false
		else:
			$HingeJoint.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, FIRE_FORCE)
			_hammer_fired = true
