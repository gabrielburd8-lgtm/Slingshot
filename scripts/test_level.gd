extends Node2D

signal projectile_launched(velocity: Vector2)

@export var max_drag_distance: float = 170.0
@export var launch_power: float = 5.4
@export var max_launch_speed: float = 1300.0
@export var trajectory_step: float = 0.12

@onready var projectile: RigidBody2D = $Projectile
@onready var band_left: Line2D = $BandLeft
@onready var band_right: Line2D = $BandRight
@onready var trajectory: Line2D = $Trajectory

var dragging: bool = false
var is_launched: bool = false

func _ready() -> void:
    reset_projectile()
    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    if is_launched:
        return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                var local_mouse = to_local(get_global_mouse_position())
                if local_mouse.distance_to(Vector2.ZERO) <= 82.0:
                    dragging = true
            elif dragging:
                launch_projectile()
                dragging = false
    elif event is InputEventMouseMotion and dragging:
        var local_mouse = to_local(get_global_mouse_position())
        var drag_vector = local_mouse
        drag_vector = drag_vector.limit_length(max_drag_distance)
        projectile.position = drag_vector
        _update_preview()
        _update_slingshot_lines()

func _process(delta: float) -> void:
    if not dragging and not is_launched:
        projectile.position = Vector2.ZERO
    _update_slingshot_lines()
    if not dragging and not is_launched:
        _update_preview()

func reset_projectile() -> void:
    is_launched = false
    dragging = false
    projectile.position = Vector2.ZERO
    projectile.linear_velocity = Vector2.ZERO
    projectile.angular_velocity = 0.0
    projectile.freeze = true
    projectile.sleeping = true
    trajectory.clear_points()
    _update_slingshot_lines()

func _update_slingshot_lines() -> void:
    var left_band_end = projectile.position + Vector2(-10, 6)
    var right_band_end = projectile.position + Vector2(10, 6)
    band_left.points = PackedVector2Array([Vector2(-18, 0), left_band_end])
    band_right.points = PackedVector2Array([Vector2(18, 0), right_band_end])

func _update_preview() -> void:
    if not projectile:
        return

    var launch_velocity = -projectile.position * launch_power
    launch_velocity = launch_velocity.limit_length(max_launch_speed)

    var points: PackedVector2Array = []
    var current_position: Vector2 = projectile.position
    var current_velocity: Vector2 = launch_velocity
    var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

    for i in range(24):
        points.append(current_position)
        current_velocity += Vector2(0.0, gravity) * trajectory_step
        current_position += current_velocity * trajectory_step
        if current_position.y > 900:
            break

    trajectory.points = points

func launch_projectile() -> void:
    if is_launched:
        return

    var launch_vector = -projectile.position
    if launch_vector.length() < 10.0:
        reset_projectile()
        return

    launch_vector = launch_vector.limit_length(max_launch_speed)
    launch_vector *= launch_power / 90.0
    projectile.freeze = false
    projectile.sleeping = false
    projectile.linear_velocity = launch_vector
    projectile.angular_velocity = 0.0
    is_launched = true
    trajectory.clear_points()
    emit_signal("projectile_launched", launch_vector)
