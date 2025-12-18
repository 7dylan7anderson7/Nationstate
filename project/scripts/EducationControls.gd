extends Control

#Primary education node variables
@onready var primary_slider: HSlider = $VBoxContainer/PrimaryPanel/VBoxContainer/PrimaryHSlider
@onready var primary_description_label: Label = $VBoxContainer/PrimaryPanel/VBoxContainer/PrimaryDescriptionLabel
@onready var primary_name_label: Label = $VBoxContainer/PrimaryPanel/VBoxContainer/HBoxContainer2/PrimaryNameLabel

#Secondary education node variables
@onready var secondary_slider: HSlider = $VBoxContainer/SecondaryPanel/VBoxContainer/SecondaryHSlider
@onready var secondary_description_label: Label = $VBoxContainer/SecondaryPanel/VBoxContainer/SecondaryDescriptionLabel
@onready var secondary_name_label: Label = $VBoxContainer/SecondaryPanel/VBoxContainer/HBoxContainer2/SecondaryNameLabel


#Higher education node variables
@onready var higher_slider: HSlider = $VBoxContainer/HigherPanel/VBoxContainer/HigherHSlider
@onready var higher_description_label: Label = $VBoxContainer/HigherPanel/VBoxContainer/HigherDescriptionLabel
@onready var higher_name_label: Label = $VBoxContainer/HigherPanel/VBoxContainer/HBoxContainer2/HigherNameLabel

#Other node variables
@onready var literacy_label = $VBoxContainer/LiteracyLabel

#Dictionary for primary education policies
const PrimaryPolicies = [
	{
		"name": "Minimal",
		"description": "Very low education spending. Only the elite have access.",
		"literacy_modifier": -.10
	},
	{
		"name": "Low",
		"description": "Low spending, enough to fund some public schooling.",
		"literacy_modifier": .5
	},
	{
		"name": "Moderate",
		"description": "Moderate levels of spending with average educational outcomes.",
		"literacy_modifier": .15
	},
	{
		"name": "High",
		"description": "High spending, enough to ensure academic sucess for most students.",
		"literacy_modifier": .25
	},
	{
		"name": "Maximum",
		"description": "Fully funded public schooling intended to create exceptional citizens.",
		"literacy_modifier": .40
	}
]

#Dictionary for secondary education policies
const SecondaryPolicies = [
	{
		"name": "Minimal",
		"description": "Very low education spending. Only the elite have access.",
		"literacy_modifier": -.10
	},
	{
		"name": "Low",
		"description": "Low spending, enough to fund some public schooling.",
		"literacy_modifier": .5
	},
	{
		"name": "Moderate",
		"description": "Moderate levels of spending with average educational outcomes.",
		"literacy_modifier": .15
	},
	{
		"name": "High",
		"description": "High spending, enough to ensure academic sucess for most students.",
		"literacy_modifier": .25
	},
	{
		"name": "Maximum",
		"description": "Fully funded public schooling intended to create exceptional citizens.",
		"literacy_modifier": .40
	}
]

#Dictionary for higher education policies
const HigherPolicies = [
	{
		"name": "Minimal",
		"description": "Very low education spending. Only the elite have access.",
		"literacy_modifier": -.10
	},
	{
		"name": "Low",
		"description": "Low spending, enough to fund some public schooling.",
		"literacy_modifier": .5
	},
	{
		"name": "Moderate",
		"description": "Moderate levels of spending with average educational outcomes.",
		"literacy_modifier": .15
	},
	{
		"name": "High",
		"description": "High spending, enough to ensure academic sucess for most students.",
		"literacy_modifier": .25
	},
	{
		"name": "Maximum",
		"description": "Fully funded public schooling intended to create exceptional citizens.",
		"literacy_modifier": .40
	}
]

#Variables for literacy modifier
var primary_literacy_modifier: float = 0
var secondary_literacy_modifier: float = 0
var higher_literacy_modifier: float = 0
var total_literacy_modifier: float = 0

#Function for updating primary education policy
func update_primary(value: int):
	var primarypolicy = PrimaryPolicies[value]
	primary_description_label.text = primarypolicy["description"]
	primary_name_label.text = primarypolicy["name"]
	GameState.primary_policy_index = value
	GameState.primary_policy = primarypolicy
	primary_slider.value = value
	primary_literacy_modifier = primarypolicy["literacy_modifier"]

#Function for updating secondary education policy
func update_secondary(value: int):
	var secondarypolicy = SecondaryPolicies[value]
	secondary_description_label.text = secondarypolicy["description"]
	secondary_name_label.text = secondarypolicy["name"]
	GameState.secondary_policy_index = value
	GameState.secondary_policy = secondarypolicy
	secondary_slider.value = value
	secondary_literacy_modifier = secondarypolicy["literacy_modifier"]

#Function for updating higher education policy
func update_higher(value: int):
	var higherpolicy = HigherPolicies[value]
	higher_description_label.text = higherpolicy["description"]
	higher_name_label.text = higherpolicy["name"]
	GameState.higher_policy_index = value
	GameState.higher_policy = higherpolicy
	higher_slider.value = value
	higher_literacy_modifier = higherpolicy["literacy_modifier"]

#Functions for slider value changes
func _on_primary_h_slider_value_changed(value: float) -> void:
	update_primary(value)

func _on_secondary_h_slider_value_changed(value: float) -> void:
	update_secondary(value)

func _on_higher_h_slider_value_changed(value: float) -> void:
	update_higher(value)

#Other functions
func update_education_labels():
	literacy_label.text = "Current Literacy: %s%%" % [snapped(EconomySystem.literacy, 0.1)]

func clear_literacy_modifier():
	total_literacy_modifier = 0

func set_literacy_modifier():
	total_literacy_modifier = primary_literacy_modifier + secondary_literacy_modifier + higher_literacy_modifier
	EconomySystem.literacy_roc = total_literacy_modifier

func _ready() -> void:
	update_education_labels()
	clear_literacy_modifier()
	update_primary(GameState.primary_policy_index)
	update_secondary(GameState.secondary_policy_index)
	update_higher(GameState.higher_policy_index)

func _on_set_education_policy_button_pressed() -> void:
	set_literacy_modifier()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
