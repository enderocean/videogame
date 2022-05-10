extends Spatial
class_name TheterAnchor

onready var body: RigidBody = get_node("AnchorBody")
onready var joint: HingeJoint = get_node("HingeJoint")
