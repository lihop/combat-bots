extends Spatial


export(int) var fling_force := 10


func fire() -> void:
	print('firing flipper hazard!')
	yield(get_tree().create_timer(1), "timeout")
	$RigidBody.apply_impulse(global_transform.origin, Vector3(0, -1 * fling_force, 0))


func _on_Area_body_entered(body):
	fire()
