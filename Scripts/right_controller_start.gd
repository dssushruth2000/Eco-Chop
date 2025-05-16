extends XRController3D

# Track the currently targeted button
var menu_target = null
var previous_menu_target = null

# Track the toggle state for the axe
var is_axe_active = false

# Optional: Environment manager to control atmospheric updates
@onready var environment_manager = get_node_or_null("/root/Walking")

func _ready():
    # Initial setup to ensure the axe is hidden and inactive by default
    var axe = get_node("/root/Walking/XROrigin3D/RightController/axe01")
    
    if axe != null:
        # Ensure the axe is hidden and inactive by default
        is_axe_active = false
        axe.visible = false
        print("DEBUG: Axe is hidden and inactive by default.")
    else:
        print("DEBUG: Axe node not found!")

func _process(delta: float) -> void:
    var start = global_position + (-global_basis.z * 0.005)
    var end = (-global_basis.z * 0.5) + start

    # Set the sword points for visualization
    $"RightLaserSword".points[0] = start
    $"RightLaserSword".points[1] = end

    # Get the raycast node
    var raycast = $"RightLaserSword/RightSwordRayCast3D"
    raycast.target_position = raycast.to_local(end)

    if raycast.is_colliding():
        var collider = raycast.get_collider()
        if collider == null:
            reset_previous_highlight()
            menu_target = null
            return

        # Traverse to find the button node
        while collider != null and not collider.name.ends_with("Button3D"):
            collider = collider.get_parent()

        # Highlight the button
        if collider != null:
            if menu_target != collider:
                reset_previous_highlight()
                menu_target = collider
                set_highlight_color(menu_target, Color(0.8, 0.8, 0.8))  # Highlight color
        else:
            reset_previous_highlight()
            menu_target = null
    else:
        reset_previous_highlight()
        menu_target = null

# Dictionary to store the original colors of buttons
var button_original_colors = {
    "StartButton3D": Color(0, 1, 0),  # Green
    "PauseButton3D": Color(0, 0, 1),  # Blue
    "QuitButton3D": Color(1, 0, 0)  # Red
}

# Function to reset the highlight
func reset_previous_highlight():
    if previous_menu_target != null and previous_menu_target != menu_target:
        if previous_menu_target.name in button_original_colors:
            set_highlight_color(previous_menu_target, button_original_colors[previous_menu_target.name])
    previous_menu_target = menu_target



# Function to set the highlight color
func set_highlight_color(button, color):
    if button is MeshInstance3D:
        if button.material_override and button.material_override is StandardMaterial3D:
            var new_material = button.material_override.duplicate()
            new_material.albedo_color = color
            button.material_override = new_material
        else:
            var new_material = StandardMaterial3D.new()
            new_material.albedo_color = color
            button.material_override = new_material
    else:
        print("Button is not a MeshInstance3D: ", button.name)


# Handles button presses from the VR controller
func _on_right_controller_button_pressed(name: String) -> void:
    if name == "ax_button":
        # Toggle axe visibility or activation
        var axe = get_node("/root/Walking/XROrigin3D/RightController/axe01")
        var right_sword = get_node("/root/Walking/XROrigin3D/RightController/RightLaserSword")
        var right_raycast = get_node("/root/Walking/XROrigin3D/RightController/RightLaserSword/RightSwordRayCast3D")
        
        if axe != null and right_sword != null and right_raycast != null:
            # Toggle the axe visibility and activation
            is_axe_active = !is_axe_active
            axe.visible = is_axe_active
            print("DEBUG: Axe visibility toggled to:", is_axe_active)

            # Toggle raycast and laser sword based on axe state
            right_sword.visible = !is_axe_active
            right_raycast.enabled = !is_axe_active
            print("DEBUG: Raycast visibility toggled to:", right_sword.visible)
        else:
            if axe == null:
                print("DEBUG: Axe node not found!")
            if right_sword == null:
                print("DEBUG: RightLaserSword node not found!")
            if right_raycast == null:
                print("DEBUG: RightSwordRayCast3D node not found!")
                
                
        ## Toggle axe visibility or activation
        #var axe = get_node("/root/Walking/XROrigin3D/RightController/axe01")
        #if axe != null:
            #is_axe_active = !is_axe_active
            #axe.visible = is_axe_active
            #print("DEBUG: Axe visibility toggled to:", is_axe_active)
        #else:
            #print("DEBUG: Axe node not found!")
            
    elif name == "by_button":
        print("by_button pressed")
        # Execute the menu action if pointing at a button
        if menu_target != null:
            print("Executing action for: ", menu_target.name)
            if menu_target.name == "StartButton3D":
                start_game()
            elif menu_target.name == "PauseButton3D":
                pause_game()
            elif menu_target.name == "QuitButton3D":
                quit_game()
        else:
            print("No button targeted.")
        
                    
    elif name == "grip_click":
        pass
        
    
        
# Menu actions
func start_game():
    print("Game Started!")
    get_tree().change_scene_to_file("res://Scenes/main.tscn")
    
  
func pause_game():
    # Toggle the paused state
    get_tree().paused = not get_tree().paused

    # Print the current state for debugging
    if get_tree().paused:
        print("Game Paused!")
    else:
        print("Game Resumed!")
  

func quit_game():
    print("Game Quit!")
    get_tree().quit()
