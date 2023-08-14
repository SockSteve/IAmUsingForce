extends Node

#export to a self made library

#func pull():
#	@export var overshootYAxis: float = 0.0
#	var lowestPoint = Vector3(self.global_transform.origin.x, self.global_transform.origin.y -1.0, self.global_transform.origin.z)
#	var grapplePointRelativYPos = closestGrapplingPoint.get_grapplingpoint_position().y - lowestPoint.y
#	var highestPointOnArc = grapplePointRelativYPos + overshootYAxis
#	if(grapplePointRelativYPos < 0):
#		highestPointOnArc = overshootYAxis
#	player.jumpToPosition(closestGrapplingPoint.get_grapplingpoint_position(), highestPointOnArc)
#
#func jumpToPosition(targetPosition: Vector3, trajectoryHeight: float):
#	_physics_body.linear_velocity = calculateJumpVelocity(_physics_body.global_transform.origin, targetPosition, trajectoryHeight)
#
#func calculateJumpVelocity(startPoint: Vector3, endPoint: Vector3, trajectoryHeight: float):
#	var gravity: float = _gravity
#	var displacementY = endPoint.y - startPoint.y;
#	var displacementXZ = Vector3(endPoint.x - startPoint.x, 0.0, endPoint.z - startPoint.z)
#
#	var velocityY = Vector3.UP * sqrt(-2 * gravity * trajectoryHeight)
#	var velocityXZ = displacementXZ / (sqrt(-2 * trajectoryHeight / gravity) + sqrt(2 * (displacementY - trajectoryHeight)/gravity))
#
#	return velocityXZ + velocityY
