extends Control

@onready var title_label = $LevelName
@onready var timer_label = $Time
var time = 0

var timer_disabled = false

func _ready():
	hide()

func _process(delta):
	time += delta
	var label = str(int(time / 60)) + ':' 
	label += str(int(time)%60) + ':' 
	label += str(int(time*1000)%1000)
	timer_label.text = label

func Update(level : Dictionary):
	if level['name'] == 'Title':
		hide()
		return 0
	
	title_label.text = level['name']
	time = 0
	timer_label.text = '00.00.000'
	
	print(level['name'])
	show()

