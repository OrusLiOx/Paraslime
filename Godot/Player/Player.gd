extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var parasite: String

var spriteBase : AnimatedSprite2D
var spriteOutline : AnimatedSprite2D

var coyoteTime
var extraJump

var facing
var dash
var dashDuration

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	spriteBase = $Sprite
	spriteOutline = $Outline
	coyoteTime = 100
	dashDuration = .25
	dash = 50
	facing = 1

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
		velocity.y = JUMP_VELOCITY
		
	elif Input.is_action_just_released("Jump") and velocity.y <0:
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
		set_anim(animation)

func set_anim(animation):
	spriteBase.play(animation)
	spriteOutline.play(animation)

func set_parasite(new):
	parasite = new

	extraJump = parasite == "Dump"
	if parasite == "Dash":
		dash = 50
