extends Camera
class_name ZoomingCamera
# Static camera that focuses on the midpoint between multiple targets. Zooms in
# and out to ensure that targets remain within view.
#
# Portions of code derived from "Make a 3d Fighting Game Style Camera in Godot
# (tutorial)" from https://www.youtube.com/watch?v=AQZmHG3h2X4 by GDQuest and
# contributors - https://gdquest.com/, released under CC-BY-4.0.


# Array of NodePaths to the nodes the camera should keep in frame.
export(Array) var targets := []
export(float) var max_fov := 70 # TODO: Hint limit max camera fov
export(float) var min_fov := 3
export(float, 0.1, 1.0) var zoom_speed := 0.5
export(float, 0.1, 0.4) var smoothing := 0.3
export(Vector2) var target_proportion := Vector2(0.7, 0.7)

var _targets := []
var _viewport_rect: Rect2


func _ready():
	fov = max_fov
	
	_viewport_rect = get_viewport().get_visible_rect()
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	
	for target in targets:
		# FIXME: Only the VehicleBody node inside the HammerBot
		# scene moves, so we need to target that instead.
		_targets.append(get_node(target).get_node("Chassis"))


func _process(delta: float) -> void:
	var midpoint := Vector3()
	for target in _targets:
		midpoint += target.global_transform.origin
	look_at(midpoint / _targets.size(), Vector3.UP)
	
	var rect := Rect2(unproject_position(midpoint), Vector2(0.5, 0.5))
	for target in _targets:
		rect = rect.expand(unproject_position(target.global_transform.origin))
	
	var new_fov := fov
	var proportion := rect.size / _viewport_rect.size
	if proportion.x > target_proportion.x or proportion.y > target_proportion.y:
		new_fov = min(fov + zoom_speed, max_fov)
	elif proportion.x < target_proportion.x or proportion.y < target_proportion.y:
		new_fov = max(fov - zoom_speed, min_fov)
	fov = lerp(fov, new_fov, smoothing)


func _on_viewport_size_changed():
	_viewport_rect = get_viewport().get_visible_rect()
