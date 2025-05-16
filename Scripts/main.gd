extends Node3D

# Variables to store XR Interface and HUD instance
var xr_interface: XRInterface
var hud  # Reference to the HUD instance
var viewport_texture  # Reference to the SubViewport texture



# Path to the plane displaying the HUD texture
@export var hud_plane_path: NodePath = "HUDPlane"
@export var sub_viewport_path: NodePath = "XROrigin3D/SubViewport"  # Path to SubViewport node

# Gas percentages
var oxygen_level = 21.0
var nitrogen_level = 78.0
var co2_level = 0.04
var others_level = 1.0

#scene
# Initialize the scene and OpenXR interface
func _ready():
    # Find the OpenXR interface
    xr_interface = XRServer.find_interface("OpenXR")
    
    # Check if OpenXR is initialized
    if xr_interface and xr_interface.is_initialized():
        print("OpenXR initialized successfully")
        
        # Disable V-Sync for VR
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
        
        # Enable XR output on the main viewport
        get_viewport().use_xr = true
    else:
        print("OpenXR not initialized, please check if your headset is connected")
    
    # Reference the HUD node in the scene tree
    hud = get_node("XROrigin3D/SubViewport/HUD")
    
    # Check if HUD is found
    if hud:
        #print("HUD found in scene tree.")
        
        # Set initial values for oxygen and nitrogen percentages
        #hud.set_oxygen_percentage(21.0)
        #hud.set_nitrogen_percentage(78.0)
        hud.set_oxygen_percentage(oxygen_level)
        hud.set_nitrogen_percentage(nitrogen_level)
        hud.set_co2_percentage(co2_level)
        hud.set_others_percentage(others_level)

    else:
        print("HUD not found in scene tree.")
        
    
    # Access the SubViewport and get its texture
    var sub_viewport = get_node(sub_viewport_path)
    if sub_viewport and sub_viewport is SubViewport:
        viewport_texture = sub_viewport.get_texture()  # Fetch texture from SubViewport
        #print("SubViewport texture obtained.")
    else:
        print("SubViewport not found at the specified path.")
    
    # Apply the SubViewport texture to the HUD plane's material
    var hud_plane = get_node(hud_plane_path)
    if hud_plane and hud_plane is MeshInstance3D:
        var material = StandardMaterial3D.new()
        material.albedo_texture = viewport_texture
        hud_plane.material_override = material
        #print("HUD texture applied to plane.")
    else:
        print("HUD plane not found at the specified path.")

# Method to update oxygen percentage
func set_oxygen_percentage(value: float):
    if hud:
        hud.set_oxygen_percentage(value)

# Method to update nitrogen percentage
func set_nitrogen_percentage(value: float):
    if hud:
        hud.set_nitrogen_percentage(value)
        
func set_co2_percentage(value: float):
    if hud:
        hud.set_co2_percentage(value)

func set_others_percentage(value: float):
    if hud:
        hud.set_others_percentage(value)



# Process function to demonstrate updating values dynamically
func _process(delta):
    pass
