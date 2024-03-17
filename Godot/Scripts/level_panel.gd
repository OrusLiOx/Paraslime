extends Panel

var path : String

func _on_play_pressed():
	get_tree().root.get_child(0).Load_From_Path(path)
