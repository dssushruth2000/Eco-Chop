extends CanvasLayer

# Variables to store oxygen and nitrogen percentages
var oxygen_percentage: float = 0.0
var nitrogen_percentage: float = 0.0
var co2_percentage: float = 0.0
var others_percentage: float = 0.0


# Setters for oxygen and nitrogen percentages
func set_oxygen_percentage(value: float):
    oxygen_percentage = value
    update_labels()

func set_nitrogen_percentage(value: float):
    nitrogen_percentage = value
    update_labels()
    
func set_co2_percentage(value: float):
    co2_percentage = value
    update_labels()

func set_others_percentage(value: float):
    others_percentage = value
    update_labels()


# Method to update the labels with the current percentages
func update_labels():
    $OxygenLabel.text = "Oxygen: %.2f%%" % oxygen_percentage
    $NitrogenLabel.text = "Nitrogen: %.2f%%" % nitrogen_percentage
    $CO2Label.text = "CO2: %.2f%%" % co2_percentage
    $OthersLabel.text = "Others: %.2f%%" % others_percentage


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    update_labels()  # Initialize labels with default values


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
