extends Control

#Set labels as variables to be updated every quarter
@onready var quarter_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/QuarterLabel
@onready var gdp_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/GDPLabel
@onready var population_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/PopulationLabel
@onready var unemployment_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/UnemploymentLabel

#Function executes on game startup
func _ready():
	update_labels()

#Updates all main menu labels with current data
func update_labels():
	quarter_label.text = " Year %s, Q%s" % [GameState.year, GameState.quarter]
	gdp_label.text = "GDP: $%sB" % [snapped(EconomySystem.total_GDP, 0.001)] #Snapped limits GDP output to 3 decimals
	population_label.text = "Population: %sM" % [snapped(EconomySystem.population, 0.01)]
	unemployment_label.text = "Unemployment: %s%%" % [snapped(EconomySystem.flux_unemployment, 0.1)]

func _on_next_quarter_button_pressed() -> void:
	GameState.next_quarter()
	EconomySystem.update_economy()
	InfrastructureSystem.update_infrastructure()
	update_labels()

#Functionality for Trade button
func _on_trade_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TradeControls.tscn")

#Functionality for Education button
func _on_education_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/EducationControls.tscn")


func _on_healthcare_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HealthcareControls.tscn")

func _on_infrastructure_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/InfrastructureControls.tscn")

func _on_test_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TestRunner.tscn")
