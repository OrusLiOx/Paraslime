extends Node

var current_level = "title"
var level_path = r"res://Scenes/Levels/"
@onready var level_container = $Level
@onready var shade = $Shade
@onready var shade_text = $Shade/Text


func _ready():
	pass
	#Load_Level("title", "Loading...")


func Load_Level(toLoad : String, message = "SLIME!"):
	current_level = toLoad
	shade_text.text = message
	shade.show()
	print(toLoad)
