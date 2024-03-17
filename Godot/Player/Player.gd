extends CharacterBody2D

var SPEED = 200.0
var JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var parasite: String = "None"

var spriteBase : AnimatedSprite2D
var spriteShine : AnimatedSprite2D
var wormOut : AnimatedSprite2D
var wormIn: AnimatedSprite2D
var sillies: Node

var coyoteTime
var extraJump
var jumping

var facing
var dash
var dashDuration

var inWater
var onSurface

var godotActive
var rainbowActive
var rainbowColorDest
@export var sillylist :Array

signal die()
signal win()
signal silly()

func _ready():
	sillies = $Sillies
	spriteBase = $Sprite
	spriteShine = $Shine
	wormOut = $Worm
	wormIn = $InnerWorm
	coyoteTime = 100
	dashDuration = .25
	dash = 50
	facing = 1
	inWater = 0
	onSurface = 0
	set_parasite(parasite)
	set_sillies(sillylist)
	
	var main = get_tree().root.get_child(0)
	if main.name == "Main":
		connect("die", main.Death)
		connect("win", main.Win)
		connect("silly", main.Silly)
		main.connect('update_sillies', self.set_sillies)
		
# Process movement and such
func _physics_process(delta):
	if Input.is_action_just_pressed("Restart"):
		emit_signal("die")
	
	jump_process(delta)
	walk_process(delta)
	swim_process(delta)
	dash_process(delta)
	
	animate(delta)

	move_and_slide()

func jump_process(delta):
	if velocity.y >0:
		jumping = false
	if !is_on_floor():
		# falling
		coyoteTime += delta
		if in_water():
			velocity.y += gravity/4 * delta
		else:
			velocity.y += gravity * delta
	else:
		# on ground
		coyoteTime = 0
		extraJump = true
		
	if Input.is_action_pressed("Jump"):
		# set stuff based on type of jump performed
		if coyoteTime < .25:
			coyoteTime = 1
		elif on_surface():
			pass
		elif Input.is_action_just_pressed("Jump") and extraJump and parasite == "Dump":
			extraJump = false
		else:
			return
		# acutal jump execution
		if in_water() and !on_surface():
			velocity.y = JUMP_VELOCITY/2
		else:
			velocity.y = JUMP_VELOCITY
		jumping = true
		
	elif velocity.y>0:
		jumping = false
	elif Input.is_action_just_released("Jump") and jumping:
		jumping = false
		velocity.y = 0

func walk_process(_delta):
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

func swim_process(_delta):
	if !in_water():
		return
	extraJump=true
	var direction = Input.get_axis("Up", "Down")
	if parasite == "Dive":
		if direction:
			# holding up or down
			if !jumping:
				velocity.y = direction * SPEED
			if !on_surface():
				jumping = false
			elif direction <0 and !jumping:
				velocity.y =0
		elif !jumping:
			if velocity.x == 0:
				# sink
				if !on_surface():
					velocity.y = gravity/40
				else:
					velocity.y =0
				velocity.y = gravity/40
			else:
				# moving vertical
				velocity.y = 0
		if !jumping:
			if velocity.y!= gravity/40:
				velocity = velocity.normalized()*SPEED
			velocity.y *= 2/3.0
	else:
		if !on_surface():
			velocity.y = gravity/-20 + direction * 40
		elif !jumping:
			velocity.y =0
	velocity.x *= 2/3.0

func dash_process(delta):
	if Input.is_action_just_pressed("Dash") and parasite == "Dash" and dash > 10:
		dash = 0
	
	# dash
	var dashTemp = dash
	if dash >=100:
		dashTemp-=100
	if dashTemp < dashDuration:
		velocity.y = 0
		velocity.x = facing*SPEED*3
		
	if dashTemp < dashDuration+.1:
		# increment dash timer
		dash+=delta
	elif is_on_floor() or in_water() or dash >=100:
		# reset dash if on floor and 2 seconds have passed since dash was executed
		dash = 50

# Animation stuff
func animate(delta):
	if parasite == "Dump":
		if extraJump:
			set_parasite_color(Color(1,0,0))
		else:
			set_parasite_color(Color(.3,.3,.3))
	elif parasite == "Dash":
		if dash<10:
			set_parasite_color(Color(.3,.3,.3))
		else:
			set_parasite_color(Color("fffa00"))
		
	
	if rainbowActive:
		rainbow_handler(delta)
	if godotActive:
		spriteBase.play("Godot")
		return
	
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
		
		if abs(velocity.y) <= gravity/40 and !(in_water() and Input.is_action_pressed("Up")):
			animation += "Float"
		elif velocity.y <=0 :
			animation += "Jump"
		else:
			animation += "Fall"
		
		if in_water() and animation == "MoveFloat":
			animation = "Dash"
		set_anim(animation)

func set_anim(animation):
	spriteBase.play(animation)
	spriteShine.play(animation)

func rainbow_handler(delta):
	var s = .5*delta
	if spriteBase.self_modulate == rainbowColorDest:
		match rainbowColorDest:
			Color(0,1,0):
				rainbowColorDest = Color(0,1,1)
			Color(0,1,1):
				rainbowColorDest = Color(0,0,1)
			Color(0,0,1):
				rainbowColorDest = Color(1,0,1)
			Color(1,0,1):
				rainbowColorDest = Color(1,0,0)
			Color(1,0,0):
				rainbowColorDest = Color(1,1,0)
			Color(1,1,0):
				rainbowColorDest = Color(0,1,0)	
	
	spriteBase.self_modulate.r = move_toward(spriteBase.self_modulate.r, rainbowColorDest.r, s)
	spriteBase.self_modulate.g = move_toward(spriteBase.self_modulate.g, rainbowColorDest.g, s)
	spriteBase.self_modulate.b = move_toward(spriteBase.self_modulate.b, rainbowColorDest.b, s)

	pass

# parasite things
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
	
	set_parasite_color(color)

	extraJump = parasite == "Dump"
	if parasite == "Dash":
		dash += 100
	
	for area in $Fear.get_overlapping_areas():
		if area.is_in_group("ParasiteSpawner"):
			if parasite_fight(parasite, area.type) == area.type:
				area.unfear()
			else:
				area.run()
		
func eat_parasite(para):
	if para.enabled and (para.type == "None"  or parasite_fight(parasite, para.type) == para.type):
		set_parasite(para.type)
		para.die()

func set_parasite_color(color):
	wormOut.modulate = color
	color.a = 62.0/255.0
	wormIn.modulate = color

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
		_:
			return new
	return current

func _on_fear_area_entered(area):
	if area.is_in_group("ParasiteSpawner"):
		if parasite_fight(parasite, area.type) != area.type:
			area.run()
	pass # Replace with function body.
	
func _on_fear_area_exited(area):
	if area.is_in_group("ParasiteSpawner"):
		area.unfear()
	pass # Replace with function body.

# set sillies
func set_sillies(active:Array):
	for i in range(0,11):
		sillies.get_child(i).visible = active.has(i)
	
	# flip y
	if active.has(-1):
		scale.y = -3*facing
	else:
		scale.y = 3*facing
	
	# rainbow
	if active.has(-2):
		rainbowActive = true
		spriteBase.self_modulate = Color(0,1,0)
		rainbowColorDest = Color(0,1,0)
	else:
		rainbowActive = false
	
	# godot
	if active.has(-3):
		godotActive = true
		spriteBase.scale = Vector2(.08,.08)
		spriteShine.visible = false
		if rainbowActive:
			spriteBase.self_modulate = Color(0,1,1)
			rainbowColorDest = Color(0,0,1)
		else:
			spriteBase.self_modulate = Color(1,1,1)
	else:
		godotActive = false
		#spriteBase.scale = Vector2(1,1)
		spriteBase.self_modulate = Color("34da2f")
		spriteShine.visible = true
		
	pass

# helper
func in_water():
	return inWater > 0

func on_surface():
	return in_water() and onSurface >0

# collisions
func _on_area_2d_area_entered(area):
	if area.is_in_group("ParasiteSpawner"):
		eat_parasite(area)
	elif area.is_in_group("Win"):
		emit_signal("win")

func _on_area_2d_body_entered(_body):
	inWater+= 1
	pass # Replace with function body.

func _on_area_2d_body_exited(_body):
	inWater-= 1
	pass # Replace with function body.

func _on_water_surface_body_entered(_body):
	onSurface+=1
	pass # Replace with function body.

func _on_water_surface_body_exited(_body):
	onSurface-=1
	pass # Replace with function body.

func _on_hazard_body_entered(_body):
	emit_signal("die")
