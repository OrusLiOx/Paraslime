extends Control

@onready var game_ui = $GameUI
@onready var title_label = $GameUI/LevelName
@onready var timer_label = $GameUI/Time
@onready var triangle = $GameUI/Triangle
var time = 0

var timer_running = false

@onready var level_select = $LevelSelect
@onready var level_select_container = $LevelSelect/ScrollContainer/VBoxContainer
@export var level_panel : PackedScene

@onready var settings = $Settings

func _ready():
	game_ui.hide()
	level_select.hide()
	settings.hide()

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
		panel.path = level['path']
		panel.get_node('Play').connect('pressed', self.Close_All)

func Update_LS(level : Dictionary):
	var panel = level_select_container.get_node(level['name'])
	if level['fastest']:
		var label = str(int(level['fastest'] / 60)) + ':' 
		label += str(int(level['fastest'])%60) + ':' 
		label += str(int(level['fastest']*1000)%1000)
		panel.get_node('BestTime').text = label
	panel.get_node('Deaths').text = "Deaths:" + str(level['deaths'])

func Close_All():
	get_tree().paused = false
	timer_running = true
	level_select.hide()
	settings.hide()

func Open_Menu():
	get_tree().paused = true
	timer_running = false
	settings.show()

func _on_exit_level_select_pressed():
	level_select.hide()

func _on_restart_pressed():
	Close_All()
	get_tree().root.get_child(0).Death()

func _on_main_menu_pressed():
	Close_All()
	get_tree().root.get_child(0).Load_Level(0)

func _on_level_selesct_pressed():
	level_select.show()

func _on_speedrun_timer_toggled(toggled_on):
	if toggled_on:
		timer_label.show()
	else:
		timer_label.hide()

func _on_para_guide_toggled(toggled_on):
	if toggled_on:
		triangle.show()
	else:
		triangle.hide()
