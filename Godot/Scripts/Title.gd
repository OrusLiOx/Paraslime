extends Control

var main
# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_tree().root.get_child(0)
	if main.name != "Main":
		print("No Mains?")
		get_tree().quit()
	$Start.connect("pressed", main.Next_Level)	

