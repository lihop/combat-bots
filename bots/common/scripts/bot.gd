extends VehicleBody


export(NodePath) var primary_weapon


onready var _primary_weapon = get_node_or_null(primary_weapon)


func _physics_process(delta):
	if Input.is_action_just_pressed("bot_weapon_primary"):
		if _primary_weapon:
			_primary_weapon.fire()
