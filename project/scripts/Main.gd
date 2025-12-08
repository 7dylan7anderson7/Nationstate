extends Control

#Set labels as variables to be updated every quarter
@onready var quarter_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/QuarterLabel
@onready var gdp_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/GDPLabel
@onready var population_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/PopulationLabel
@onready var unemployment_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/UnemploymentLabel

#Funciton executes on game startup
func _ready():
	EconomySystem.update_economy()
	update_labels()

#Updates all main menu labels with current data
func update_labels():
	quarter_label.text = " Year %s, Q%s" % [GameState.year, GameState.quarter]
	gdp_label.text = "GDP: $%sB" % [EconomySystem.GDP]
	population_label.text = "Population: %sM" % [EconomySystem.population]
	unemployment_label.text = "Unemployment: %s%%" % [int(EconomySystem.unemployment)] #Convert to int to get a whole percentage


func _on_next_quarter_button_pressed() -> void:
	GameState.next_quarter()
	EconomySystem.update_economy()
	update_labels()
