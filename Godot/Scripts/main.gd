extends Node

var current_level = 0
var level_path = r"res://Scenes/Levels/"

var levels = ["title.tscn", "blue_tutorial.tscn", "red_tutorial.tscn", "yellow_tutorial.tscn", "swap_tutorial.tscn", "dash.tscn", "water_dash.tscn"]

@onready var level_container = $Level
@onready var shade = $Shade
@onready var shade_text = $Shade/Text

func _ready():
	Load_Level(6, "Loading...")

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
	var level = load(level_path + levels[toLoad]).instantiate()
	level_container.add_child(level)
	shade.hide()

func Death():
	Load_Level(current_level)
	
func Win():
	Next_Level()
