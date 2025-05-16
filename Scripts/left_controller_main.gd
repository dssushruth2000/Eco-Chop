#in this, removing the unwanted parts from below code
extends XRController3D

func _on_left_controller_button_pressed(name: String) -> void:
    if name == "ax_button":  
        pass
            
    elif name == "by_button":
        pass
        ## Toggle HUD visibility
        #var menu = get_node("/root/Walking/XROrigin3D/LeftController/DiegeticMenu")
        #
        #if menu:
            #menu.visible = !menu.visible
            #print("Menu visibility toggled:", menu.visible)
        #else:
            #print("Menu not found!")
                  
    elif name == "grip_click":
        XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)
        print("Pose recentered signal received!")
        print("grip_click_button pressed")
        
