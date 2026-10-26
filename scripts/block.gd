extends RigidBody2D

signal block_broken(block: Node)

@export var impact_threshold: float = 220.0

func _ready() -> void:
    contact_monitor = true
    max_contacts_reported = 8
    linear_damp = 0.65
    angular_damp = 0.8
    sleeping = false

func check_hit() -> void:
    if linear_velocity.length() >= impact_threshold:
        emit_signal("block_broken", self)
        queue_free()
