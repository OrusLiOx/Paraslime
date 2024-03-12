extends Area2D


func _ready():
	hide()

func _on_body_entered(body):
	show()
