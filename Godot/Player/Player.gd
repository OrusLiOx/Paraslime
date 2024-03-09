extends CharacterBody2D

var SPEED = 300.0
var JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var parasite: String = "None"

var spriteBase : AnimatedSprite2D
var spriteShine : AnimatedSprite2D
var wormOut : AnimatedSprite2D
var wormIn: AnimatedSprite2D

var coyoteTime
var extraJump
var jumping

var facing
var dash
var dashDuration

var inWater

signal die()

func _ready():
	spriteBase = $Sprite
	spriteShine = $Shine
	wormOut = $Worm
	wormIn = $InnerWorm
	coyoteTime = 100
	dashDuration = .25
	dash = 50
	facing = 1
	inWater = 0
	set_parasite(parasite)

# Process movement and such
func _physics_process(delta):
	jump_process(delta)
	walk_process(delta)
	dash_process(delta)
	
	animate()

	move_and_slide()

func jump_process(delta):
	if !is_on_floor():
		# falling
		coyoteTime += delta
		velocity.y += gravity * delta
	else:
		# on ground
		coyoteTime = 0
		extraJump = true
		
	if Input.is_action_just_pressed("Jump"):
		# set stuff based on type of jump performed
		if coyoteTime < .25:
			coyoteTime = 1
		elif extraJump and parasite == "Dump":
			extraJump = false
		else:
			return
		
		# acutal jump execution
		jumping = true
		velocity.y = JUMP_VELOCITY
	elif velocity.y>0:
		jumping = false
	elif Input.is_action_just_released("Jump") and jumping:
		jumping = false
		velocity.y = 0

func walk_process(delta):
	var direction = Input.get_axis("Left", "Right")
	
	# deal with turning
	if dash>dashDuration:
		if direction < 0 and facing!=-1:
			scale.x *=-1
			facing = -1
		elif direction > 0 and facing != 1:
			scale.x *=-1
			facing = 1
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if inWater > 0:
		direction = Input.get_axis("Up", "Down")
		if direction:
			jumping = false
			velocity.y = direction * SPEED
		elif !jumping:
			if velocity.x == 0:
				velocity.y = gravity/20
			else:
				velocity.y = move_toward(velocity.y, 0, SPEED)
		if !jumping:
			velocity.y/=2
		velocity.x/=2
	pass

func dash_process(delta):
	if Input.is_action_just_pressed("Dash") and parasite == "Dash" and dash > 10:
		dash = 0
	
	# dash for 1 seconds
	if dash < dashDuration:
		velocity.y = 0
		velocity.x = facing*SPEED*2
		
	if dash < dashDuration+.1:
		# increment dash timer
		dash+=delta
	elif is_on_floor():
		# reset dash if on floor and 2 seconds have passed since dash was executed
		dash = 50

# Animation stuff
func animate():
	if dash < dashDuration:
		set_anim("Dash")
	elif is_on_floor():
		if abs(velocity.x)>0:
			set_anim("Run") 
		else:
			set_anim("Idle")
		pass
	else:
		var animation
		if abs(velocity.x)<10:
			animation = "Neutral"
		else:
			animation = "Move"
		
		if abs(velocity.y) < 10:
			animation += "Float"
		elif velocity.y <0:
			animation += "Jump"
		else:
			animation += "Fall"
		
		if inWater>0 and animation == "MoveFloat":
			animation = "Dash"
		set_anim(animation)

func set_anim(animation):
	spriteBase.play(animation)
	spriteShine.play(animation)

# external interaction
func set_parasite(new):	
	var color = Color(1,1,1)
	match (new):
		"Dump":
			color = Color(1,0,0)
		"Dash":
			color = Color("fffa00")
		"Dive":
			color = Color("0067ff")
		_:
			new = "None"
		
	parasite = new
	
	wormIn.play(parasite)
	wormOut.play(parasite)
	
	wormOut.modulate = color
	color.a = 62.0/255.0
	wormIn.modulate = color

	extraJump = parasite == "Dump"
	if parasite == "Dash":
		dash = 50
	
func _on_area_2d_area_entered(area):
	if area.is_in_group("Water"):
		if parasite !="Dive":
			emit_signal("die")
		inWater+= 1
	elif area.is_in_group("ParasiteSpawner"):
		if area.enabled:
			area.die()
			set_parasite(area.type)

func _on_area_2d_area_exited(area):
	if area.is_in_group("Water"):
		inWater-=1

func _on_fear_area_entered(area):
	if area.is_in_group("ParasiteSpawner"):
		if parasite_fight(parasite, area.type) != area.type:
			area.run()
	pass # Replace with function body.
	
func _on_fear_area_exited(area):
	if area.is_in_group("ParasiteSpawner"):
		if parasite_fight(parasite, area.type) != area.type:
			area.respawn()
	pass # Replace with function body.

func parasite_fight(current, new):
	match(current):
		"Dive":
			if new == "Dash":
				return "Dash"
		"Dash":
			if new == "Dump":
				return "Dump"
		"Dump":
			if new == "Dive":
				return "Dive"
	return current


