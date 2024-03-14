extends Node

var current_level = 0
var level_path = r"res://Scenes/Levels/"

var levels = [
	{
		'name' : 'Title',
		'path' : 'title.tscn',
		'completed' : null,
		'fastest' : null,
		'deaths' : null,
		'silly' : null,
		'secret_found' : null
	}, 
	{
		'name' : 'Red Tutorial',
		'path' : 'red_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	},  
	{
		'name' : 'Blue Tutorial',
		'path' : 'blue_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	},
	{
		'name' : 'Yellow Tutorial',
		'path' : 'yellow_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	},  
	{
		'name' : 'Swap Tutorial',
		'path' : 'swap_tutorial.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	}, 
	{
		'name' : 'Dash Block',
		'path' : 'dash_block.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	},  
	{
		'name' : 'Fast Switch',
		'path' : 'fast_switch.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	}, 
	{
		'name' : 'Jump! Jump! Jump!',
		'path' : 'jump_jump_jump.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	}, 
	{
		'name' : 'Water Dash',
		'path' : 'water_dash.tscn',
		'completed' : false,
		'fastest' : null,
		'deaths' : 0,
		'silly' : null,
		'secret_found' : false
	}
]

@onready var level_container = $Level
@onready var shade = $Shade
@onready var shade_text = $Shade/Text

func _ready():
	Load_Level(0, "Loading...")

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
	shade.hide()

func Death():
	Load_Level(current_level)
	
func Win():
	Next_Level()
