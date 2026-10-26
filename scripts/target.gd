extends Area2D

signal target_destroyed(target: Node)

var destroyed: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    monitoring = true

func _on_body_entered(body: Node) -> void:
    if destroyed:
        return
    if body is RigidBody2D:
        if body.linear_velocity.length() >= 75.0:
            destroy_target()

func destroy_target() -> void:
    if destroyed:
        return
    destroyed = true
    monitoring = false
    visible = false
    emit_signal("target_destroyed", self)
    queue_free()
