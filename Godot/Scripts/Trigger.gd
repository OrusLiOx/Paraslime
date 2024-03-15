extends Area2D


func _ready():
	hide()

func _on_body_entered(body):
	if self.name == "Secret":
		if body.name == 'Player':
			body.emit_signal("silly")
	show()
