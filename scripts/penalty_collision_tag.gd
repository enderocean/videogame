extends Node
class_name PenaltyCollisionTag
# Used to tag physical objects to given points from the player if the ROV touch them
# Can remove from the minimum to the maximum amount of points

export(int, 0, 5000) var points: int = 250
