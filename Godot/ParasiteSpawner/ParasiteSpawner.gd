extends Area2D

@export var type : String
@export var respawnTime : float
var anim : AnimatedSprite2D
var timer : Timer
var enabled = true
var l
var fear
var shine:Node2D
var shineTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim = $AnimatedSprite2D
	shine = $AnimatedSprite2D/Shine 
	timer = $Timer
	shineTimer = 0
	fear = false 
	match(type):
		"Dash":
			anim.play("Dash")
			modulate = Color("fffa00")
			$CollisionShape2D.shape.set_size(Vector2(12,10))
			$CollisionShape2D.position = Vector2(0,2)
			l = 4
			pass
		"Dump":
			anim.play("Dump")
			modulate = Color(1,0,0)
			$CollisionShape2D.shape.set_size(Vector2(8,14))
			$CollisionShape2D.position = Vector2(0,0)
			l = 2
			pass
		"Dive":
			anim.play("Dive")
			modulate = Color("0067ff")
			$CollisionShape2D.shape.set_size(Vector2(14,5))
			$CollisionShape2D.position = Vector2(0,4.5)
			l = 4
			pass
		_:
			type = "None"
			anim.play("None")
			anim.self_modulate = Color("00ffffba")
			$Fountain.visible = true
			$CollisionShape2D.shape.set_size(Vector2(12,14))
			$CollisionShape2D.position = Vector2(0,0)
			shine.visible = true
			l = 10
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if anim.animation_finished and anim.frame == l and enabled:
		anim.play(type)
	
	if type == "None":
		shineTimer += delta
		shine.position.y = floor(shineTimer*10)+-7 #-7 to 2
		if shineTimer >=1:
			shineTimer = 0
	pass

func die():
	timer.start(respawnTime)
	enabled = false
	if type == "None":
		anim.play("NoneLeave")
		shineTimer = 0
	else:
		anim.play("Hide")
	pass

func run():
	if type == "None":
		return
	fear = true
	if enabled:
		enabled = false
		anim.play_backwards(type+"Arrive")
	pass

func unfear():
	if enabled:
		return
	
	fear = false
	if timer.is_stopped():
		respawn()
		
func respawn():
	anim.play(type+"Arrive")
	enabled = true
	fear = false
	enabled = true
	shineTimer=-.1
	for area in get_overlapping_areas():
		if area.is_in_group("Player"):
			area.get_parent().eat_parasite(self)

func _on_timer_timeout():
	timer.stop()
	if fear:
		return
	respawn()
	pass # Replace with function body.
