extends XRController3D

# Track references for chopped tree parts
var trunk_body_reference = null
var top_body_reference = null
var trees_chopped = 0

# Track the currently targeted button
var menu_target = null
var previous_menu_target = null

# Track the toggle state for the axe
var is_axe_active = false

# Optional: Environment manager to control atmospheric updates
@onready var environment_manager = get_node_or_null("/root/Walking")
@onready var popup_node = get_node("/root/Walking/XROrigin3D/XRCamera3D/PopupChain")
var popup_instance = null  # Reference to the popup instance

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
        
        
func on_area_entered(body: Node3D) -> void:
    print("DEBUG: Area Entered Triggered. Body name:", body.name)
    
    if not is_axe_active:
        print("DEBUG: Axe is not active, ignoring collision.")
        return  # Ignore collision if axe is not active
    
           
    if body.name.begins_with("Trunk"):  # Ensure it's a trunk collision
        print("DEBUG: Axe hit the tree trunk")
        
        # Traverse up to find the parent tree node
        var tree = body
        while tree and not tree.name.begins_with("Tree"):
            tree = tree.get_parent()
        
        if tree and tree.name.begins_with("Tree"):
            print("DEBUG: Found tree instance:", tree.name)
            chop_tree(tree)
            
        else:
            print("DEBUG: Could not find parent Tree node")
            
    if body.name.begins_with("Top"):  # Ensure it's a trunk collision
        print("DEBUG: Axe hit the Tree Top")
        
        # Traverse up to find the parent tree node
        var tree = body
        while tree and not tree.name.begins_with("Tree"):
            tree = tree.get_parent()
        
        if tree and tree.name.begins_with("Tree"):
            print("DEBUG: Found tree instance:", tree.name)
            chop_tree(tree)
        else:
            print("DEBUG: Could not find parent Tree node")
    


 # Dictionary to store the original colors of buttons
var button_original_colors = {
    "StartButton3D": Color(0, 1, 0),  # Green
    "PauseButton3D": Color(0, 0, 1),  # Blue
    "QuitButton3D": Color(1, 0, 0)  # Red
}

func show_popup():
    if popup_node:
        popup_node.visible = true
        print("Popup displayed.")
    else:
        print("Popup node not found!")

    # Start a timer to hide the popup after 5 seconds
    var popup_timer = Timer.new()
    popup_timer.wait_time = 6.0  # 6 seconds
    popup_timer.one_shot = true
    add_child(popup_timer)
    popup_timer.connect("timeout", Callable(self, "_hide_popup"))
    popup_timer.start()
    trees_chopped = 0

func _hide_popup():
        popup_node.visible = false
        print("Popup hidden.")
    

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


# Chop the tree when detected
func chop_tree(tree):
    print("Chopping tree:", tree.name)
    
    # Play chop sound if collision with tree is detected
    if tree.has_node("ChopSound"):
        tree.get_node("ChopSound").play()
    
    # Find trunk and top nodes
    var trunk = tree.get_node_or_null("Trunk")
    var top = tree.get_node_or_null("Top")

    if trunk and top:
        print("Trunk and Top detected. Proceeding to chop.")
        add_fall_animation(trunk, top)
        
        if environment_manager:
            environment_manager.oxygen_level = max(0, environment_manager.oxygen_level - 2)  # Adjust decrement values as needed
            environment_manager.nitrogen_level = max(0, environment_manager.nitrogen_level - 7)
            environment_manager.co2_level = max(0, environment_manager.co2_level + 5)
            environment_manager.others_level = max(0, environment_manager.others_level + 4)

        # Update the HUD to reflect the new values
            environment_manager.set_oxygen_percentage(environment_manager.oxygen_level)
            environment_manager.set_nitrogen_percentage(environment_manager.nitrogen_level)
            environment_manager.set_co2_percentage(environment_manager.co2_level)
            environment_manager.set_others_percentage(environment_manager.others_level)
            # Increment trees chopped and check for popup
            trees_chopped += 1
            print("Tree chopped! Total trees chopped:", trees_chopped)
            if trees_chopped > 2:
                show_popup()
        print("Tree chopped! Atmospheric values updated.")
    else:
        print("Error: EnvironmentManager not found.")
        
# Add physics-based falling effect
func add_fall_animation(trunk, top):
    # Create RigidBody3D nodes for physics-based falling
    var trunk_body = RigidBody3D.new()
    var top_body = RigidBody3D.new()

    # Add bodies to the scene
    get_parent().add_child(trunk_body)
    get_parent().add_child(top_body)

    # Match the global transforms and scales of the original parts
    trunk_body.global_transform = trunk.global_transform
    top_body.global_transform = top.global_transform

    # Create mesh instances for visual representation
    var trunk_mesh_instance = MeshInstance3D.new()
    trunk_mesh_instance.mesh = trunk.get_mesh()
    trunk_mesh_instance.scale = trunk.scale
    trunk_body.add_child(trunk_mesh_instance)

    var top_mesh_instance = MeshInstance3D.new()
    top_mesh_instance.mesh = top.get_mesh()
    top_mesh_instance.scale = top.scale
    top_body.add_child(top_mesh_instance)

    # Attach collision shapes to the new bodies
    add_collision_shape(trunk, trunk_body)
    add_collision_shape(top, top_body)

    ## Apply randomized falling motion with gravity
    trunk_body.linear_velocity = Vector3(randf() * 2 - 1, -5, randf() * 2 - 1)
    trunk_body.angular_velocity = Vector3(randf() * 2 - 1, randf() * 2 - 1, randf() * 2 - 1)
#
    #top_body.linear_velocity = Vector3(randf() * 2 - 1, -4, randf() * 2 - 1)
    #top_body.angular_velocity = Vector3(randf() * 2 - 1, randf() * 2 - 1, randf() * 2 - 1)

    # Apply more realistic physics-based motion
    #trunk_body.linear_velocity = Vector3(randf() * 0.5 - 0.25, -3, randf() * 0.5 - 0.25)  # Slight horizontal displacement
    #trunk_body.angular_velocity = Vector3(randf() * 1 - 0.5, randf() * 0.5 - 0.25, 0)  # Subtle rotation

    #top_body.linear_velocity = Vector3(randf() * 0.3 - 0.15, -2.5, randf() * 0.3 - 0.15)  # Less intense displacement for the top
    #top_body.angular_velocity = Vector3(randf() * 1.5 - 0.75, randf() * 0.5 - 0.25, randf() * 0.2 - 0.1)  # Slight spin effect
    
    top_body.linear_velocity = Vector3(0, -5, 0)
    top_body.angular_velocity = Vector3(0.4, 0.3, 0.1)
    
    # Adjust gravity to slow down the motion for more realism (optional)
    trunk_body.gravity_scale = 1.2
    top_body.gravity_scale = 1.2
    
    # Remove original nodes
    trunk.queue_free()
    top.queue_free()

    # Store references for cleanup
    trunk_body_reference = trunk_body
    top_body_reference = top_body

    # Set timer to remove tree parts after 5 seconds
    var timer = Timer.new()
    timer.wait_time = 4.0
    timer.one_shot = true
    add_child(timer)
    timer.connect("timeout", Callable(self, "_on_disappearance_timeout"))
    timer.start()

# Add collision shape to the RigidBody3D
func add_collision_shape(original, body):
    var collision_shape_node = find_collision_shape_recursive(original)
    if collision_shape_node:
        var collision_shape = CollisionShape3D.new()
        collision_shape.shape = collision_shape_node.shape.duplicate()
        collision_shape.scale = collision_shape_node.scale * original.scale
        body.add_child(collision_shape)

# Helper function to recursively search for CollisionShape3D
func find_collision_shape_recursive(node):
    for child in node.get_children():
        if child is CollisionShape3D:
            return child  # Return the CollisionShape3D node if found
        elif child.get_child_count() > 0:  # Search recursively
            var result = find_collision_shape_recursive(child)
            if result:
                return result
    return null

# Cleanup fallen tree parts
func _on_disappearance_timeout():
    if is_instance_valid(trunk_body_reference):
        trunk_body_reference.queue_free()
    if is_instance_valid(top_body_reference):
        top_body_reference.queue_free()
    trunk_body_reference = null
    top_body_reference = null
    print("Tree parts removed after 5 seconds.")

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
