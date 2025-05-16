extends XROrigin3D

@onready var left_controller = $LeftController  # Left VR controller node
@onready var right_controller = $RightController  # Right VR controller node
@onready var xr_camera = $XRCamera3D  # Camera node to determine the facing direction

# Movement parameters
@export var swing_threshold: float = 0.01  # Minimum hand movement distance to count as a "swing"
@export var speed_multiplier: float = 5.0  # Speed multiplier for movement
@export var friction: float = 0.1  # Friction factor to slow down movement
var player_velocity: Vector3 = Vector3.ZERO
var left_hand_last_position: Vector3
var right_hand_last_position: Vector3

# Movement control flag
var movement_enabled: bool = false

func _ready():
    # Ensure controllers are initialized before detecting hand motion
    if not (left_controller and right_controller and xr_camera):
        print("Error: One or more VR nodes are missing in the scene tree.")
        return

    # Record the initial positions of the controllers
    left_hand_last_position = left_controller.global_transform.origin
    right_hand_last_position = right_controller.global_transform.origin

func _process(delta: float):

    if left_controller and right_controller:
        if movement_enabled:  # Only analyze hand movement if movement is enabled
            analyze_hand_movement()
            apply_movement(delta)

func analyze_hand_movement():
    # Get current positions of controllers
    var current_left_pos = left_controller.global_transform.origin
    var current_right_pos = right_controller.global_transform.origin

    # Calculate vertical movement distances
    var left_swing_distance = abs(current_left_pos.y - left_hand_last_position.y)
    var right_swing_distance = abs(current_right_pos.y - right_hand_last_position.y)

    # Check if the hand swings exceed the threshold
    if left_swing_distance > swing_threshold or right_swing_distance > swing_threshold:
        # Get the forward direction based on the camera's orientation
        var forward_direction = -xr_camera.global_transform.basis.z.normalized()

        # Restrict movement to x and z axes (ignore y-axis)
        forward_direction.y = 0
        forward_direction = forward_direction.normalized()

        player_velocity += forward_direction * speed_multiplier * 0.1  # Scale speed incrementally

    # Update previous positions for swing detection
    left_hand_last_position = current_left_pos
    right_hand_last_position = current_right_pos

func apply_movement(delta):
    # Move the player forward using velocity
    global_transform.origin += player_velocity * delta

    # Apply friction to reduce velocity over time
    player_velocity = player_velocity.lerp(Vector3.ZERO, friction)

# Handle trigger button press
func _on_right_controller_button_pressed(name: String) -> void:
    if name == "trigger_click":
        print("Trigger pressed")
        movement_enabled = true

# Handle trigger button release
func _on_right_controller_button_released(name: String) -> void:
    if name == "trigger_click":
        print("Trigger released")
        movement_enabled = false


#func _on_left_controller_button_pressed(name: String) -> void:
    #if name == "trigger_click":
        #print("Trigger pressed")
        #movement_enabled = true
#
#func _on_left_controller_button_released(name: String) -> void:
    #if name == "trigger_click":
        #print("Trigger released")
        #movement_enabled = false
