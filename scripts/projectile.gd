extends RigidBody2D

signal hit_registered(body: Node)

func _ready() -> void:
    contact_monitor = true
    max_contacts_reported = 8
    linear_damp = 0.7
    angular_damp = 0.75
    freeze = false
    sleeping = false

func activate_from_slingshot(velocity: Vector2) -> void:
    linear_velocity = velocity
    angular_velocity = 0.0
    sleeping = false
    freeze = false
    emit_signal("hit_registered", self)
