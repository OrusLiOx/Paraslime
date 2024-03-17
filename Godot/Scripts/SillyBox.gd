extends CheckBox

var num = 0
signal silly_update(num, tog)

func _ready():
	var main = get_tree().root.get_child(0)
	connect('silly_update', main.Silly_Update)

func _on_toggled(toggled_on):
	emit_signal('silly_update', num, toggled_on)
