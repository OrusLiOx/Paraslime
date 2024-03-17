extends Control

func _ready():
	var main = get_tree().root.get_child(0)
	if main.name != "Main":
		print("No Mains?")
		get_tree().quit()
	$Start.connect("pressed", main.Next_Level)
	$Settings.connect('pressed', main.get_node('UI').Open_Menu)

func _on_exit_pressed():
	get_tree().quit()

