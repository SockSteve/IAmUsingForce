extends Area3D
class_name HurtboxDetectionArea3D
#only gets called when enteringg and exiting an area

func get_closest_area():
	var overlapping_areas = get_overlapping_areas()
	
	if overlapping_areas.is_empty():
		return null

	var closest_dist = INF
	var current_closest = null

	for area in overlapping_areas:
		var dist = global_position.distance_to(area.global_position)
		if dist < closest_dist:
			closest_dist = dist
			current_closest = area

	return current_closest
