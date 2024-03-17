extends Node

var current_level = 0
var level_path = r"res://Scenes/Levels/"
@onready var UI = $UI

var levels = [
	{
		'name' : 'Title',
		'path' : 'Title.tscn',
		'completed' : null,
		'fastest' : null,
		'deaths' : null,
		'silly_id' : null,
		'silly_name' : null,
		'secret_found' : null,
		'toggled' : false
	}, 
	{
		'name' : 'Red Tutorial',
		'path' : 'red_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 5,
		'silly_name' : 'COIN',
		'secret_found' : false,
		'toggled' : false
	},  
	{
		'name' : 'Blue Tutorial',
		'path' : 'blue_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 3,
		'silly_name' : 'Floaty',
		'secret_found' : false,
		'toggled' : false
	},
	{
		'name' : 'Yellow Tutorial',
		'path' : 'yellow_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 4,
		'silly_name' : 'Dorky Glasses',
		'secret_found' : false,
		'toggled' : false
	},  
	{
		'name' : 'Swap Tutorial',
		'path' : 'swap_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 0,
		'silly_name' : 'Cross Eyed',
		'secret_found' : false,
		'toggled' : false
	}, 
	{
		'name' : 'Dash Block',
		'path' : 'dash_block.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 10,
		'silly_name' : 'Fish',
		'secret_found' : false,
		'toggled' : false
	},  
	{
		'name' : 'Double Jump',
		'path' : 'double_jump.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 1,
		'silly_name' : 'Mustache Mode',
		'secret_found' : false,
		'toggled' : false
	},
	{
		'name' : 'Casual Swim',
		'path' : 'swim.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : -1,
		'silly_name' : 'Upslime Down',
		'secret_found' : false,
		'toggled' : false
	},
	{
		'name' : 'A Little Bit Of Everything',
		'path' : 'a_little_of_everything.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : -2,
		'silly_name' : 'Rainbow Slime',
		'secret_found' : false,
		'toggled' : false
	},
	{
		'name' : 'Fast Switch',
		'path' : 'fast_switch.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 2,
		'silly_name' : 'Sun Hat',
		'secret_found' : false,
		'toggled' : false
	}, 
	{
		'name' : 'Jump! Jump! Jump!',
		'path' : 'jump_jump_jump.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : -3,
		'silly_name' : 'Become God(ot)',
		'secret_found' : false,
		'toggled' : false
	}, 
	{
		'name' : 'Water Dash',
		'path' : 'water_dash.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly_id' : 7,
		'silly_name' : 'Overcompensating',
		'secret_found' : false,
		'toggled' : false
	}
]

@onready var level_container = $Level
@onready var shade = $Shade
@onready var shade_text = $Shade/Text

signal update_sillies(sillies)

func _ready():
	$Background/Clouds.emitting = true
	Load_Level(0, "Loading...")
	UI.Build_LS(levels.slice(1))

func Next_Level(message = "SLIME!"):
	if current_level+1 == len(levels):
		Load_Level(0, message)
	else:
		Load_Level(1 + current_level, message)

func Load_Level(toLoad : int, message = "SLIME!"):
	current_level = toLoad
	shade_text.text = message
	shade.show()
	for child in level_container.get_children():
		child.queue_free()
	await get_tree().create_timer(.5).timeout
	var level = load(level_path + levels[toLoad]['path']).instantiate()
	level_container.add_child(level)
	self.Update_Sillies()
	UI.Update_Game(levels[toLoad])
	shade.hide()
	
func Load_From_Path(path):
	for i in range(0, len(levels)):
		if levels[i]['path'] == path:
			Load_Level(i)
			break
	return 0

func Death():
	if not levels[current_level]['deaths']:
		Load_Level(current_level)
		return 0
	levels[current_level]['deaths'] += 1
	UI.Update_LS(levels[current_level])
	Load_Level(current_level)
	
func Win():
	# Update Level Completed Status
	levels[current_level]['completed'] = true
	
	# Update Level Time
	var new_time = UI.time
	if not levels[current_level]['fastest']:
		levels[current_level]['fastest'] = new_time
	elif new_time < levels[current_level]['fastest']:
		levels[current_level]['fastest'] = new_time
	
	UI.Update_LS(levels[current_level])
	Next_Level()

func Silly():
	levels[current_level]['secret_found'] = true
	UI.Add_Silly(levels[current_level]['silly_name'], current_level)
	
func Update_Sillies():
	var sillies = []
	for level in levels:
		if level['silly_id'] != null:
			if level['secret_found'] and level['toggled']:
				sillies.append(level['silly_id'])
	emit_signal('update_sillies', sillies)
	
func Silly_Update(num, tog):
	levels[int(num)]['toggled'] = tog
	Update_Sillies()
