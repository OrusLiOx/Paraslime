extends Control

@onready var game_ui = $GameUI
@onready var title_label = $GameUI/LevelName
@onready var timer_label = $GameUI/Time
var time = 0

var timer_disabled = false
var timer_running = false

@onready var level_select = $LevelSelect
@onready var level_select_container = $LevelSelect/ScrollContainer/VBoxContainer
@export var level_panel : PackedScene

func _ready():
	game_ui.hide()
	level_select.hide()

func _process(delta):
	if !timer_running:
		return 0
	time += delta
	var label = str(int(time / 60)) + ':' 
	label += str(int(time)%60) + ':' 
	label += str(int(time*1000)%1000)
	timer_label.text = label

func Update_Game(level : Dictionary):
	if level['name'] == 'Title':
		timer_running = false
		game_ui.hide()
		return 0
	
	title_label.text = level['name']
	time = 0
	timer_label.text = '00.00.000'
	timer_running = true
	
	game_ui.show()

# DO NOT TOUCH, I wrote this at 2:24 am and I no longer remember what I did to make it work
func Build_LS(levels : Array):
	level_select_container.custom_minimum_size.y = len(levels) * 160
	for level in levels:
		var panel = level_panel.instantiate()
		level_select_container.add_child(panel)
		panel.name = level['name'] 
		var toUpdate = panel.get_node('LevelName')
		toUpdate.text = level['name']
		toUpdate = panel.get_node('BestTime')
		toUpdate.text = '00:00:000'
		toUpdate = panel.get_node('Deaths')
		toUpdate.text = "Deaths:" + str(level['deaths'])

func Update_LS(level : Dictionary):
	var panel = level_select_container.get_node(level['name'])
	if level['fastest']:
		var label = str(int(level['fastest'] / 60)) + ':' 
		label += str(int(level['fastest'])%60) + ':' 
		label += str(int(level['fastest']*1000)%1000)
		panel.get_node('BestTime').text = label
	panel.get_node('Deaths').text = "Deaths:" + str(level['deaths'])


func _on_back_button_pressed():
	get_tree().paused = false
	timer_running = true
	level_select.hide()

func _on_open_menu_pressed():
	get_tree().paused = true
	timer_running = false
	level_select.show()
